import Core
import Foundation

/// Use case for linking notes together
public final class LinkNotesUseCase {
    private let noteRepository: NoteRepositoryProtocol

    public init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }

    public func execute(sourceNoteId: String, targetNoteId: String) async throws -> Note {
        // Get source note
        var sourceNote = try await noteRepository.getNote(by: sourceNoteId)

        // Verify target note exists
        _ = try await noteRepository.getNote(by: targetNoteId)

        // Add link if not already linked
        if !sourceNote.linkedNoteIds.contains(targetNoteId) {
            sourceNote.linkedNoteIds.append(targetNoteId)
            sourceNote = try await noteRepository.updateNote(sourceNote)
        }

        return sourceNote
    }
}
