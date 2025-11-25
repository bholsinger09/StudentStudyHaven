import Core
import Foundation

/// Mock implementation of NoteRepository for development and testing
public final class MockNoteRepositoryImpl: NoteRepositoryProtocol {
    private var notes: [String: Note] = [:]

    public init() {}

    public func getNotes(for classId: String) async throws -> [Note] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        return notes.values.filter { $0.classId == classId }
    }

    public func getNote(by id: String) async throws -> Note {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let note = notes[id] else {
            throw AppError.notFound("Note not found")
        }

        return note
    }

    public func getLinkedNotes(for noteId: String) async throws -> [Note] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let note = notes[noteId] else {
            throw AppError.notFound("Note not found")
        }

        return note.linkedNoteIds.compactMap { notes[$0] }
    }

    public func createNote(_ note: Note) async throws -> Note {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        notes[note.id] = note
        return note
    }

    public func updateNote(_ note: Note) async throws -> Note {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard notes[note.id] != nil else {
            throw AppError.notFound("Note not found")
        }

        var updatedNote = note
        updatedNote.updatedAt = Date()
        notes[note.id] = updatedNote
        return updatedNote
    }

    public func deleteNote(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard notes[id] != nil else {
            throw AppError.notFound("Note not found")
        }

        notes.removeValue(forKey: id)
    }

    public func searchNotes(query: String, classId: String?) async throws -> [Note] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        var filteredNotes = Array(notes.values)

        if let classId = classId {
            filteredNotes = filteredNotes.filter { $0.classId == classId }
        }

        let lowercasedQuery = query.lowercased()
        return filteredNotes.filter {
            $0.title.lowercased().contains(lowercasedQuery)
                || $0.content.lowercased().contains(lowercasedQuery)
                || $0.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
}
