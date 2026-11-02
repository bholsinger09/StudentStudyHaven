import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of FlashcardRepositoryProtocol
/// Uses Apple's native CloudKit for flashcard data persistence
public class CloudKitFlashcardRepositoryImpl: FlashcardRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.flashcard.rawValue
    
    // Cache for in-memory storage
    private var flashcardCache: [String: Flashcard] = [:]
    private var flashcardsForClassCache: [String: [Flashcard]] = [:]
    private var updateSubject = PassthroughSubject<DataChange<Flashcard>, Never>()
    private var flashcardsSubject = PassthroughSubject<[Flashcard], Never>()
    
    public init() {
        // Subscribe to flashcard changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all flashcards for a class
    public func getFlashcards(for classId: String) async throws -> [Flashcard] {
        let predicate = NSPredicate(format: "classId == %@", classId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let flashcards = records.compactMap { record in
            Flashcard.fromCKRecord(record)
        }
        
        // Cache them
        flashcards.forEach { flashcard in
            flashcardCache[flashcard.id] = flashcard
        }
        flashcardsForClassCache[classId] = flashcards
        
        return flashcards
    }
    
    /// Fetch a single flashcard by ID
    public func getFlashcard(by id: String) async throws -> Flashcard {
        // Check cache first
        if let cached = flashcardCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let flashcard = Flashcard.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        flashcardCache[id] = flashcard
        return flashcard
    }
    
    /// Create a new flashcard
    public func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        let record = flashcard.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        flashcardCache[flashcard.id] = flashcard
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .added, item: flashcard))
        
        return flashcard
    }
    
    /// Create multiple flashcards
    public func createFlashcards(_ flashcards: [Flashcard]) async throws -> [Flashcard] {
        for flashcard in flashcards {
            _ = try await createFlashcard(flashcard)
        }
        return flashcards
    }
    
    /// Update an existing flashcard
    public func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        let record = flashcard.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        flashcardCache[flashcard.id] = flashcard
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .modified, item: flashcard))
        flashcardsSubject.send([flashcard])
        
        return flashcard
    }
    
    /// Delete a flashcard
    public func deleteFlashcard(id: String) async throws {
        if flashcardCache[id] == nil {
            _ = try await getFlashcard(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        let deletedFlashcard = flashcardCache.removeValue(forKey: id)
        
        // Notify subscribers
        if let flashcard = deletedFlashcard {
            updateSubject.send(DataChange(type: .removed, item: flashcard))
        }
    }
    
    // MARK: - Observers
    
    /// Observe all flashcards for a class
    public func observeFlashcards(for classId: String) -> AnyPublisher<[Flashcard], Never> {
        // Return cached flashcards immediately, then listen for updates
        if let cached = flashcardsForClassCache[classId] {
            flashcardsSubject.send(cached)
        }
        
        return flashcardsSubject.eraseToAnyPublisher()
    }
    
    /// Observe changes to flashcards for a class
    public func observeFlashcardChanges(for classId: String) -> AnyPublisher<DataChange<Flashcard>, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        flashcardCache.removeAll()
        flashcardsForClassCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension Flashcard {
    /// Convert Flashcard to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.flashcard.rawValue, recordID: recordID)
        
        record["id"] = id
        record["classId"] = classId
        record["userId"] = userId
        record["front"] = front
        record["back"] = back
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        
        // Encode optional fields
        if let lastReviewedAt = lastReviewedAt {
            record["lastReviewedAt"] = lastReviewedAt
        }
        
        // Encode arrays
        if !noteIds.isEmpty {
            record["noteIds"] = noteIds as NSArray
        }
        
        return record
    }
    
    /// Create Flashcard from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Flashcard? {
        let id = record.recordID.recordName
        guard let classId = record["classId"] as? String,
              let userId = record["userId"] as? String,
              let front = record["front"] as? String,
              let back = record["back"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }
        
        let lastReviewedAt = record["lastReviewedAt"] as? Date
        let noteIds = (record["noteIds"] as? [String]) ?? []
        
        return Flashcard(
            id: id,
            classId: classId,
            userId: userId,
            front: front,
            back: back,
            noteIds: noteIds,
            lastReviewedAt: lastReviewedAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
