import Core
import Foundation

/// Use case for getting notes for a class
public final class GetNotesUseCase {
    private let noteRepository: NoteRepositoryProtocol

    public init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }

    public func execute(classId: String) async throws -> [Note] {
        return try await noteRepository.getNotes(for: classId)
    }
}
