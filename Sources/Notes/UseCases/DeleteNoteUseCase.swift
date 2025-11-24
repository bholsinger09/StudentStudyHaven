import Foundation
import Core

/// Use case for deleting a note
public final class DeleteNoteUseCase {
    private let noteRepository: NoteRepositoryProtocol
    
    public init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }
    
    /// Delete a note
    /// - Parameter noteId: The ID of the note to delete
    /// - Throws: AppError if deletion fails
    public func execute(noteId: UUID) async throws {
        try await noteRepository.deleteNote(id: noteId)
    }
}
