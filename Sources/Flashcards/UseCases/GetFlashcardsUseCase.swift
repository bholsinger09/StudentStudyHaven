import Core
import Foundation

/// Use case for getting flashcards for a class
public final class GetFlashcardsUseCase {
    private let flashcardRepository: FlashcardRepositoryProtocol

    public init(flashcardRepository: FlashcardRepositoryProtocol) {
        self.flashcardRepository = flashcardRepository
    }

    public func execute(classId: String) async throws -> [Flashcard] {
        return try await flashcardRepository.getFlashcards(for: classId)
    }
}
