import Foundation
import Core

/// Use case for getting linked notes
public final class GetLinkedNotesUseCase {
    private let noteRepository: NoteRepositoryProtocol
    
    public init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }
    
    public func execute(noteId: UUID) async throws -> [Note] {
        return try await noteRepository.getLinkedNotes(for: noteId)
    }
}
