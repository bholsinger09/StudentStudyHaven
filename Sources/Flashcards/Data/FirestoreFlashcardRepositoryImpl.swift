import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of FlashcardRepositoryProtocol
/// Handles flashcard CRUD and batch operations
public class FirestoreFlashcardRepositoryImpl: FlashcardRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "flashcards"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all flashcards for a class
    public func getFlashcards(for classId: String) async throws -> [Flashcard] {
        return try await database.query(
            collectionName,
            where: [("classId", classId)],
            as: Flashcard.self
        )
    }
    
    /// Fetch a single flashcard by ID
    public func getFlashcard(by id: String) async throws -> Flashcard {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: Flashcard.self)
    }
    
    /// Create a single flashcard
    public func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        let path = "\(collectionName)/\(flashcard.id)"
        try await database.set(flashcard, at: path)
        return flashcard
    }
    
    /// Create multiple flashcards in a batch operation
    /// More efficient than individual creates when adding many cards at once
    public func createFlashcards(_ flashcards: [Flashcard]) async throws -> [Flashcard] {
        guard !flashcards.isEmpty else { return [] }
        
        try await database.batch { batch in
            for flashcard in flashcards {
                let path = "\(self.collectionName)/\(flashcard.id)"
                guard let encoded = try? JSONEncoder().encode(flashcard),
                      let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
                    continue // Skip encoding errors in batch
                }
                batch.setData(dict, forDocument: Firestore.firestore().document(path))
            }
        }
        
        return flashcards
    }
    
    /// Update a flashcard
    public func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        let path = "\(collectionName)/\(flashcard.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(flashcard),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode flashcard"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return flashcard
    }
    
    /// Delete a flashcard
    public func deleteFlashcard(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all flashcards for a class
    public func observeFlashcards(for classId: String) -> AnyPublisher<[Flashcard], Never> {
        let subject = CurrentValueSubject<[Flashcard], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: Flashcard.self,
            onUpdate: { flashcards in
                // Filter flashcards for this class
                let filtered = flashcards.filter { $0.classId == classId }
                subject.send(filtered)
            },
            onError: { error in
                print("❌ Error observing flashcards: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to flashcards in a class
    public func observeFlashcardChanges(for classId: String) -> AnyPublisher<DataChange<Flashcard>, Never> {
        let subject = PassthroughSubject<DataChange<Flashcard>, Never>()
        
        let listener = database.listenToCollection(
            collectionName,
            as: Flashcard.self,
            onUpdate: { flashcards in
                // Emit changes for this class's flashcards
                let classFlashcards = flashcards.filter { $0.classId == classId }
                classFlashcards.forEach { flashcard in
                    let change = DataChange(type: .modified, item: flashcard)
                    subject.send(change)
                }
            },
            onError: { error in
                print("❌ Error observing flashcard changes: \(error)")
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
