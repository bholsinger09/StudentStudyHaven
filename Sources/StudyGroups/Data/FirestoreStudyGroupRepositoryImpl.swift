import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of StudyGroupRepositoryProtocol
/// Uses the DatabaseService from FirebaseIntegration module for all Firestore operations
public class FirestoreStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "studyGroups"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all study groups for a given user (as member)
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        return try await database.query(
            collectionName,
            where: [("memberIds", userId)],
            as: StudyGroup.self
        )
    }
    
    /// Fetch a single study group by ID
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: StudyGroup.self)
    }
    
    /// Fetch public study groups (optionally filtered by class)
    public func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        var predicates: [(String, Any)] = [
            ("collegeId", collegeId),
            ("isPublic", true)
        ]
        
        if let classId = classId {
            predicates.append(("classId", classId))
        }
        
        return try await database.query(
            collectionName,
            where: predicates,
            as: StudyGroup.self
        )
    }
    
    /// Create a new study group
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        let path = "\(collectionName)/\(studyGroup.id)"
        try await database.set(studyGroup, at: path)
        return studyGroup
    }
    
    /// Update an existing study group
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        let path = "\(collectionName)/\(studyGroup.id)"
        
        // Encode the model to dictionary for Firestore update
        guard let encoded = try? JSONEncoder().encode(studyGroup),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode study group"])
        }
        
        // Update timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return studyGroup
    }
    
    /// Delete a study group
    public func deleteStudyGroup(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    /// Add a member to a study group
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(groupId)"
        let updateData: [String: Any] = [
            "memberIds": FieldValue.arrayUnion([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudyGroup(by: groupId)
    }
    
    /// Remove a member from a study group
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(groupId)"
        let updateData: [String: Any] = [
            "memberIds": FieldValue.arrayRemove([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudyGroup(by: groupId)
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all study groups for a user
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        let subject = CurrentValueSubject<[StudyGroup], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: StudyGroup.self,
            onUpdate: { groups in
                // Filter groups where user is a member
                let filtered = groups.filter { $0.memberIds.contains(userId) }
                subject.send(filtered)
            },
            onError: { error in
                print("Error observing study groups: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to a specific study group
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        let subject = PassthroughSubject<DataChange<StudyGroup>, Never>()
        
        let path = "\(collectionName)/\(groupId)"
        let listener = database.listenToDocument(
            at: path,
            as: StudyGroup.self,
            onUpdate: { group in
                let change = DataChange(type: .modified, item: group)
                subject.send(change)
            },
            onError: { error in
                print("Error observing study group changes: \(error)")
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
