import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of NoteRepositoryProtocol
/// Uses DatabaseService for Firestore operations
public class FirestoreNoteRepositoryImpl: NoteRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "notes"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all notes for a class
    public func getNotes(for classId: String) async throws -> [Note] {
        return try await database.query(
            collectionName,
            where: [("classId", classId)],
            as: Note.self
        )
    }
    
    /// Fetch a single note by ID
    public func getNote(by id: String) async throws -> Note {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: Note.self)
    }
    
    /// Fetch notes linked to a specific note
    public func getLinkedNotes(for noteId: String) async throws -> [Note] {
        // First get the note to find its linkedNoteIds
        let note = try await getNote(by: noteId)
        
        // If no linked notes, return empty array
        guard !note.linkedNoteIds.isEmpty else { return [] }
        
        // Fetch all notes and filter by linkedNoteIds
        // NOTE: Firestore doesn't support 'in' queries with arrays natively
        // So we fetch all and filter client-side (acceptable for MVP)
        let allNotes = try await database.query(
            collectionName,
            where: [("classId", note.classId)],
            as: Note.self
        )
        
        return allNotes.filter { note.linkedNoteIds.contains($0.id) }
    }
    
    /// Create a new note
    public func createNote(_ note: Note) async throws -> Note {
        let path = "\(collectionName)/\(note.id)"
        try await database.set(note, at: path)
        return note
    }
    
    /// Update an existing note
    public func updateNote(_ note: Note) async throws -> Note {
        let path = "\(collectionName)/\(note.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(note),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode note"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return note
    }
    
    /// Delete a note
    public func deleteNote(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    /// Search notes by query string
    /// NOTE: Firestore doesn't support full-text search natively.
    /// This implementation fetches notes and filters client-side.
    /// For production, consider Algolia, Meilisearch, or similar.
    public func searchNotes(query: String, classId: String?) async throws -> [Note] {
        let searchTerm = query.lowercased()
        
        // If classId provided, search within that class
        if let classId = classId {
            let notes = try await getNotes(for: classId)
            return notes.filter { note in
                note.title.lowercased().contains(searchTerm) ||
                note.content.lowercased().contains(searchTerm) ||
                note.tags.contains { $0.lowercased().contains(searchTerm) }
            }
        } else {
            // Search all notes - fetch from all classes
            // NOTE: This could be slow with many notes. Consider pagination.
            let allNotes = try await database.query(
                collectionName,
                as: Note.self
            )
            return allNotes.filter { note in
                note.title.lowercased().contains(searchTerm) ||
                note.content.lowercased().contains(searchTerm) ||
                note.tags.contains { $0.lowercased().contains(searchTerm) }
            }
        }
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all notes for a class
    public func observeNotes(for classId: String) -> AnyPublisher<[Note], Never> {
        let subject = CurrentValueSubject<[Note], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: Note.self,
            onUpdate: { notes in
                // Filter notes for this class
                let filtered = notes.filter { $0.classId == classId }
                subject.send(filtered)
            },
            onError: { error in
                print("❌ Error observing notes: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to notes in a class
    public func observeNoteChanges(for classId: String) -> AnyPublisher<DataChange<Note>, Never> {
        let subject = PassthroughSubject<DataChange<Note>, Never>()
        
        let listener = database.listenToCollection(
            collectionName,
            as: Note.self,
            onUpdate: { notes in
                // Emit changes for this class's notes
                let classNotes = notes.filter { $0.classId == classId }
                classNotes.forEach { note in
                    let change = DataChange(type: .modified, item: note)
                    subject.send(change)
                }
            },
            onError: { error in
                print("❌ Error observing note changes: \(error)")
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
