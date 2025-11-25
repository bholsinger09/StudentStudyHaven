import Core
import Foundation

/// Use case for creating a note
public final class CreateNoteUseCase {
    private let noteRepository: NoteRepositoryProtocol

    public init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }

    public func execute(note: Note) async throws -> Note {
        guard !note.title.isEmpty else {
            throw AppError.invalidData("Note title cannot be empty")
        }

        guard !note.content.isEmpty else {
            throw AppError.invalidData("Note content cannot be empty")
        }

        return try await noteRepository.createNote(note)
    }
}
