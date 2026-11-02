import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of ClassRepositoryProtocol
/// Uses DatabaseService for all Firestore operations
public class FirestoreClassRepositoryImpl: ClassRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "classes"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all classes for a user
    public func getClasses(for userId: String) async throws -> [Class] {
        return try await database.query(
            collectionName,
            where: [("userId", userId)],
            as: Class.self
        )
    }
    
    /// Fetch a single class by ID
    public func getClass(by id: String) async throws -> Class {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: Class.self)
    }
    
    /// Create a new class
    public func createClass(_ classItem: Class) async throws -> Class {
        let path = "\(collectionName)/\(classItem.id)"
        try await database.set(classItem, at: path)
        return classItem
    }
    
    /// Update an existing class
    public func updateClass(_ classItem: Class) async throws -> Class {
        let path = "\(collectionName)/\(classItem.id)"
        
        // Encode model to dictionary for Firestore update
        guard let encoded = try? JSONEncoder().encode(classItem),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode class"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return classItem
    }
    
    /// Delete a class
    public func deleteClass(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all classes for a user
    public func observeClasses(for userId: String) -> AnyPublisher<[Class], Never> {
        let subject = CurrentValueSubject<[Class], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: Class.self,
            onUpdate: { classes in
                // Filter classes for this user
                let filtered = classes.filter { $0.userId == userId }
                subject.send(filtered)
            },
            onError: { error in
                print("❌ Error observing classes: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to classes for a user
    public func observeClassChanges(for userId: String) -> AnyPublisher<DataChange<Class>, Never> {
        let subject = PassthroughSubject<DataChange<Class>, Never>()
        
        let listener = database.listenToCollection(
            collectionName,
            as: Class.self,
            onUpdate: { classes in
                // Emit changes for user's classes
                let userClasses = classes.filter { $0.userId == userId }
                userClasses.forEach { classItem in
                    let change = DataChange(type: .modified, item: classItem)
                    subject.send(change)
                }
            },
            onError: { error in
                print("❌ Error observing class changes: \(error)")
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
