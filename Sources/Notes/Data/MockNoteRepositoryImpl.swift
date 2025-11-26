import Combine
import Core
import Foundation

/// Mock implementation of NoteRepository for development and testing
public final class MockNoteRepositoryImpl: NoteRepositoryProtocol {
    private var notes: [String: Note] = [:]
    private let notesSubject = CurrentValueSubject<[Note], Never>([])
    private let changesSubject = PassthroughSubject<DataChange<Note>, Never>()
    private var isObserving = false

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

        if isObserving {
            changesSubject.send(DataChange(type: .added, item: note))
            updateNotesSubject()
        }

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

        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: updatedNote))
            updateNotesSubject()
        }

        return updatedNote
    }

    public func deleteNote(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let deletedNote = notes[id] else {
            throw AppError.notFound("Note not found")
        }

        notes.removeValue(forKey: id)

        if isObserving {
            changesSubject.send(DataChange(type: .removed, item: deletedNote))
            updateNotesSubject()
        }
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

    // MARK: - Real-time listeners

    public func observeNotes(for classId: String) -> AnyPublisher<[Note], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialNotes = try await getNotes(for: classId)
                notesSubject.send(initialNotes)
            } catch {
                notesSubject.send([])
            }
        }
        return notesSubject.eraseToAnyPublisher()
    }

    public func observeNoteChanges(for classId: String) -> AnyPublisher<DataChange<Note>, Never> {
        isObserving = true
        return
            changesSubject
            .filter { $0.item.classId == classId }
            .eraseToAnyPublisher()
    }

    public func stopObserving() {
        isObserving = false
    }

    // MARK: - Private helpers

    private func updateNotesSubject() {
        let allNotes = Array(notes.values)
        notesSubject.send(allNotes)
    }
}
