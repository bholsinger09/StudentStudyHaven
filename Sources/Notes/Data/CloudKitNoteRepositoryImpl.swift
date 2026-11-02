import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of NoteRepositoryProtocol
/// Uses Apple's native CloudKit for note data persistence
public class CloudKitNoteRepositoryImpl: NoteRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.note.rawValue
    
    // Cache for in-memory storage
    private var noteCache: [String: Note] = [:]
    private var notesForClassCache: [String: [Note]] = [:]
    private var updateSubject = PassthroughSubject<DataChange<Note>, Never>()
    private var notesSubject = PassthroughSubject<[Note], Never>()
    
    public init() {
        // Subscribe to note changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all notes for a class
    public func getNotes(for classId: String) async throws -> [Note] {
        let predicate = NSPredicate(format: "classId == %@", classId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let notes = records.compactMap { record in
            Note.fromCKRecord(record)
        }
        
        // Cache them
        notes.forEach { note in
            noteCache[note.id] = note
        }
        notesForClassCache[classId] = notes
        
        return notes
    }
    
    /// Fetch a single note by ID
    public func getNote(by id: String) async throws -> Note {
        // Check cache first
        if let cached = noteCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let note = Note.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        noteCache[id] = note
        return note
    }
    
    /// Get notes linked to a specific note
    public func getLinkedNotes(for noteId: String) async throws -> [Note] {
        let predicate = NSPredicate(format: "linkedNoteIds CONTAINS %@", noteId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        return records.compactMap { Note.fromCKRecord($0) }
    }
    
    /// Create a new note
    public func createNote(_ note: Note) async throws -> Note {
        let record = note.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        noteCache[note.id] = note
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .added, item: note))
        
        return note
    }
    
    /// Update an existing note
    public func updateNote(_ note: Note) async throws -> Note {
        let record = note.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        noteCache[note.id] = note
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .modified, item: note))
        notesSubject.send([note])
        
        return note
    }
    
    /// Delete a note
    public func deleteNote(id: String) async throws {
        if noteCache[id] == nil {
            _ = try await getNote(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        let deletedNote = noteCache.removeValue(forKey: id)
        
        // Notify subscribers
        if let note = deletedNote {
            updateSubject.send(DataChange(type: .removed, item: note))
        }
    }
    
    /// Search notes by query text
    public func searchNotes(query: String, classId: String?) async throws -> [Note] {
        var predicateFormat = "content CONTAINS %@ OR title CONTAINS %@"
        var predicateArgs: [Any] = [query, query]
        
        if let classId = classId {
            predicateFormat += " AND classId == %@"
            predicateArgs.append(classId)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        return records.compactMap { Note.fromCKRecord($0) }
    }
    
    // MARK: - Observers
    
    /// Observe all notes for a class
    public func observeNotes(for classId: String) -> AnyPublisher<[Note], Never> {
        // Return cached notes immediately, then listen for updates
        if let cached = notesForClassCache[classId] {
            notesSubject.send(cached)
        }
        
        return notesSubject.eraseToAnyPublisher()
    }
    
    /// Observe changes to notes for a class
    public func observeNoteChanges(for classId: String) -> AnyPublisher<DataChange<Note>, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        noteCache.removeAll()
        notesForClassCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension Note {
    /// Convert Note to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CloudKitRecord.RecordType.note.rawValue)
        record.setObject(id as NSString, forKey: "id")
        record.setObject(classId as NSString, forKey: "classId")
        record.setObject(userId as NSString, forKey: "userId")
        record.setObject(title as NSString, forKey: "title")
        record.setObject(content as NSString, forKey: "content")
        
        // Encode dates
        let dateFormatter = ISO8601DateFormatter()
        record.setObject(dateFormatter.string(from: createdAt) as NSString, forKey: "createdAt")
        record.setObject(dateFormatter.string(from: updatedAt) as NSString, forKey: "updatedAt")
        
        // Encode linked notes and tags
        if !linkedNoteIds.isEmpty {
            record.setObject(linkedNoteIds as NSArray, forKey: "linkedNoteIds")
        }
        
        if !tags.isEmpty {
            record.setObject(tags as NSArray, forKey: "tags")
        }
        
        return record
    }
    
    /// Create Note from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Note? {
        guard let id = record["id"] as? String,
              let classId = record["classId"] as? String,
              let userId = record["userId"] as? String,
              let title = record["title"] as? String,
              let content = record["content"] as? String else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        var createdAt = Date()
        var updatedAt = Date()
        
        if let createdAtString = record["createdAt"] as? String,
           let parsed = dateFormatter.date(from: createdAtString) {
            createdAt = parsed
        }
        
        if let updatedAtString = record["updatedAt"] as? String,
           let parsed = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsed
        }
        
        let linkedNoteIds = (record["linkedNoteIds"] as? [String]) ?? []
        let tags = (record["tags"] as? [String]) ?? []
        
        return Note(
            id: id,
            classId: classId,
            userId: userId,
            title: title,
            content: content,
            linkedNoteIds: linkedNoteIds,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
