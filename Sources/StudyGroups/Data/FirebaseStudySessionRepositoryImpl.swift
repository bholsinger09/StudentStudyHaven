import Core
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Foundation

/// Firebase implementation of GroupStudySessionRepositoryProtocol
/// Handles study session management using Firestore
public class FirebaseStudySessionRepositoryImpl: GroupStudySessionRepositoryProtocol {
    
    private let firestore = Firestore.firestore()
    private let sessionsCollection = "studySessions"
    
    private var listenerRegistration: ListenerRegistration?
    private var sessionsSubject = CurrentValueSubject<[GroupStudySession], Never>([])
    private var changesSubject = PassthroughSubject<DataChange<GroupStudySession>, Never>()
    
    public init() {}
    
    // MARK: - GroupStudySessionRepositoryProtocol Implementation
    
    public func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        do {
            let snapshot = try await firestore
                .collection(sessionsCollection)
                .whereField("studyGroupId", isEqualTo: groupId)
                .order(by: "scheduledAt", descending: false)
                .getDocuments()
            
            let sessions = try snapshot.documents.compactMap { document in
                try document.data(as: GroupStudySession.self)
            }
            
            return sessions
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        do {
            let now = Date()
            
            let snapshot = try await firestore
                .collection(sessionsCollection)
                .whereField("attendeeIds", arrayContains: userId)
                .whereField("scheduledAt", isGreaterThan: Timestamp(date: now))
                .whereField("status", isEqualTo: GroupStudySession.SessionStatus.scheduled.rawValue)
                .order(by: "scheduledAt", descending: false)
                .limit(to: 20)
                .getDocuments()
            
            let sessions = try snapshot.documents.compactMap { document in
                try document.data(as: GroupStudySession.self)
            }
            
            return sessions
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getStudySession(by id: String) async throws -> GroupStudySession {
        do {
            let document = try await firestore
                .collection(sessionsCollection)
                .document(id)
                .getDocument()
            
            guard let session = try? document.data(as: GroupStudySession.self) else {
                throw AppError.notFound("Study session not found")
            }
            
            return session
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        do {
            var newSession = session
            newSession.createdAt = Date()
            newSession.updatedAt = Date()
            
            let docRef = firestore.collection(sessionsCollection).document(newSession.id)
            try docRef.setData(from: newSession)
            
            return newSession
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        do {
            var updatedSession = session
            updatedSession.updatedAt = Date()
            
            let docRef = firestore.collection(sessionsCollection).document(updatedSession.id)
            try docRef.setData(from: updatedSession, merge: true)
            
            return updatedSession
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func deleteStudySession(id: String) async throws {
        do {
            try await firestore
                .collection(sessionsCollection)
                .document(id)
                .delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        do {
            let docRef = firestore.collection(sessionsCollection).document(sessionId)
            let document = try await docRef.getDocument()
            
            guard var session = try? document.data(as: GroupStudySession.self) else {
                throw AppError.notFound("Study session not found")
            }
            
            // Add attendee if not already present
            if !session.attendeeIds.contains(userId) {
                session.attendeeIds.append(userId)
                session.updatedAt = Date()
                
                try docRef.setData(from: session)
            }
            
            return session
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        do {
            let docRef = firestore.collection(sessionsCollection).document(sessionId)
            let document = try await docRef.getDocument()
            
            guard var session = try? document.data(as: GroupStudySession.self) else {
                throw AppError.notFound("Study session not found")
            }
            
            // Remove attendee
            session.attendeeIds.removeAll { $0 == userId }
            session.updatedAt = Date()
            
            try docRef.setData(from: session)
            
            return session
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - Real-time Listeners
    
    public func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        listenerRegistration = firestore
            .collection(sessionsCollection)
            .whereField("studyGroupId", isEqualTo: groupId)
            .order(by: "scheduledAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    return
                }
                
                let sessions = documents.compactMap { document in
                    try? document.data(as: GroupStudySession.self)
                }
                
                self?.sessionsSubject.send(sessions)
            }
        
        return sessionsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        listenerRegistration = firestore
            .collection(sessionsCollection)
            .document(sessionId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot,
                      let session = try? snapshot.data(as: GroupStudySession.self) else {
                    return
                }
                
                // For single document changes, always treat as modified
                let change = DataChange(type: .modified, item: session)
                self?.changesSubject.send(change)
            }
        
        return changesSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Private Helper Methods
    
    private func mapFirestoreError(_ error: Error) -> AppError {
        if let firestoreError = error as NSError? {
            switch firestoreError.code {
            case FirestoreErrorCode.notFound.rawValue:
                return AppError.notFound("Study session not found")
            case FirestoreErrorCode.permissionDenied.rawValue:
                return AppError.unauthorized
            case FirestoreErrorCode.unavailable.rawValue:
                return AppError.networkError("Network unavailable")
            default:
                return AppError.unknown(error.localizedDescription)
            }
        }
        return AppError.unknown(error.localizedDescription)
    }
}
