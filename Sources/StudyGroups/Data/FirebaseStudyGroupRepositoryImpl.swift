import Core
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Foundation

/// Firebase implementation of StudyGroupRepositoryProtocol
/// Handles study group management using Firestore
public class FirebaseStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    
    private let firestore = Firestore.firestore()
    private let studyGroupsCollection = "studyGroups"
    
    private var listenerRegistration: ListenerRegistration?
    private var groupsSubject = CurrentValueSubject<[StudyGroup], Never>([])
    private var changesSubject = PassthroughSubject<DataChange<StudyGroup>, Never>()
    
    public init() {}
    
    // MARK: - StudyGroupRepositoryProtocol Implementation
    
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        do {
            // Get groups where user is a member
            let memberSnapshot = try await firestore
                .collection(studyGroupsCollection)
                .whereField("memberIds", arrayContains: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let groups = try memberSnapshot.documents.compactMap { document in
                try document.data(as: StudyGroup.self)
            }
            
            return groups
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        do {
            var query: Query = firestore
                .collection(studyGroupsCollection)
                .whereField("collegeId", isEqualTo: collegeId)
                .whereField("isPublic", isEqualTo: true)
            
            if let classId = classId {
                query = query.whereField("classId", isEqualTo: classId)
            }
            
            let snapshot = try await query
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let groups = try snapshot.documents.compactMap { document in
                try document.data(as: StudyGroup.self)
            }
            
            return groups
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        do {
            let document = try await firestore
                .collection(studyGroupsCollection)
                .document(id)
                .getDocument()
            
            guard let studyGroup = try? document.data(as: StudyGroup.self) else {
                throw AppError.notFound("Study group not found")
            }
            
            return studyGroup
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        do {
            var newGroup = studyGroup
            newGroup.createdAt = Date()
            newGroup.updatedAt = Date()
            
            let docRef = firestore.collection(studyGroupsCollection).document(newGroup.id)
            try docRef.setData(from: newGroup)
            
            return newGroup
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        do {
            var updatedGroup = studyGroup
            updatedGroup.updatedAt = Date()
            
            let docRef = firestore.collection(studyGroupsCollection).document(updatedGroup.id)
            try docRef.setData(from: updatedGroup, merge: true)
            
            return updatedGroup
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func deleteStudyGroup(id: String) async throws {
        do {
            // Delete all related sessions first
            let sessionsSnapshot = try await firestore
                .collection("studySessions")
                .whereField("studyGroupId", isEqualTo: id)
                .getDocuments()
            
            // Delete all related messages
            let messagesSnapshot = try await firestore
                .collection("groupMessages")
                .whereField("studyGroupId", isEqualTo: id)
                .getDocuments()
            
            // Batch delete
            let batch = firestore.batch()
            
            for document in sessionsSnapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            for document in messagesSnapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Delete the group itself
            let groupRef = firestore.collection(studyGroupsCollection).document(id)
            batch.deleteDocument(groupRef)
            
            try await batch.commit()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        do {
            let docRef = firestore.collection(studyGroupsCollection).document(groupId)
            let document = try await docRef.getDocument()
            
            guard var studyGroup = try? document.data(as: StudyGroup.self) else {
                throw AppError.notFound("Study group not found")
            }
            
            // Check if group is full
            if let maxMembers = studyGroup.maxMembers,
               studyGroup.memberIds.count >= maxMembers {
                throw AppError.invalidData("Study group is full")
            }
            
            // Add member if not already present
            if !studyGroup.memberIds.contains(userId) {
                studyGroup.memberIds.append(userId)
                studyGroup.updatedAt = Date()
                
                try docRef.setData(from: studyGroup)
            }
            
            return studyGroup
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        do {
            let docRef = firestore.collection(studyGroupsCollection).document(groupId)
            let document = try await docRef.getDocument()
            
            guard var studyGroup = try? document.data(as: StudyGroup.self) else {
                throw AppError.notFound("Study group not found")
            }
            
            // Remove member
            studyGroup.memberIds.removeAll { $0 == userId }
            studyGroup.updatedAt = Date()
            
            try docRef.setData(from: studyGroup)
            
            return studyGroup
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - Real-time Listeners
    
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        listenerRegistration = firestore
            .collection(studyGroupsCollection)
            .whereField("memberIds", arrayContains: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    return
                }
                
                let groups = documents.compactMap { document in
                    try? document.data(as: StudyGroup.self)
                }
                
                self?.groupsSubject.send(groups)
            }
        
        return groupsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        listenerRegistration = firestore
            .collection(studyGroupsCollection)
            .document(groupId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot,
                      let studyGroup = try? snapshot.data(as: StudyGroup.self) else {
                    return
                }
                
                // For single document changes, we always treat it as modified
                let change = DataChange(type: .modified, item: studyGroup)
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
                return AppError.notFound("Study group not found")
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
