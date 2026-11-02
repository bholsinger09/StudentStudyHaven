import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of GroupStudySessionRepositoryProtocol
/// Manages study sessions for groups
public class FirestoreGroupStudySessionRepositoryImpl: GroupStudySessionRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "groupSessions"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all study sessions for a group
    public func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        return try await database.query(
            collectionName,
            where: [("groupId", groupId)],
            as: GroupStudySession.self
        )
    }
    
    /// Fetch upcoming sessions for a user
    /// A session is upcoming if the user is an attendee and scheduledAt is in the future
    public func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        // Fetch all sessions and filter client-side
        // (Firestore doesn't support array contains + date comparison in single query)
        let allSessions = try await database.query(
            collectionName,
            as: GroupStudySession.self
        )
        
        let now = Date()
        return allSessions
            .filter { session in
                session.attendeeIds.contains(userId) && session.scheduledAt > now
            }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }
    
    /// Fetch a single study session by ID
    public func getStudySession(by id: String) async throws -> GroupStudySession {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: GroupStudySession.self)
    }
    
    /// Create a new study session
    public func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        let path = "\(collectionName)/\(session.id)"
        try await database.set(session, at: path)
        return session
    }
    
    /// Update a study session
    public func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        let path = "\(collectionName)/\(session.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(session),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode session"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return session
    }
    
    /// Delete a study session
    public func deleteStudySession(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    /// Add an attendee to a study session
    public func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        let path = "\(collectionName)/\(sessionId)"
        let updateData: [String: Any] = [
            "attendeeIds": FieldValue.arrayUnion([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudySession(by: sessionId)
    }
    
    /// Remove an attendee from a study session
    public func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        let path = "\(collectionName)/\(sessionId)"
        let updateData: [String: Any] = [
            "attendeeIds": FieldValue.arrayRemove([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudySession(by: sessionId)
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all study sessions for a group
    public func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        let subject = CurrentValueSubject<[GroupStudySession], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: GroupStudySession.self,
            onUpdate: { sessions in
                // Filter sessions for this group
                let filtered = sessions.filter { $0.studyGroupId == groupId }
                subject.send(filtered)
            },
            onError: { error in
                print("❌ Error observing study sessions: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to a specific study session
    public func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        let subject = PassthroughSubject<DataChange<GroupStudySession>, Never>()
        
        let path = "\(collectionName)/\(sessionId)"
        let listener = database.listenToDocument(
            at: path,
            as: GroupStudySession.self,
            onUpdate: { session in
                let change = DataChange(type: .modified, item: session)
                subject.send(change)
            },
            onError: { error in
                print("❌ Error observing session changes: \(error)")
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Stop all real-time listeners
    public func stopObserving() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
    
    deinit {
        stopObserving()
    }
}
