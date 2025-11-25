import Core
import Foundation

/// Use case for creating a flashcard manually
public final class CreateFlashcardUseCase {
    private let flashcardRepository: FlashcardRepositoryProtocol

    public init(flashcardRepository: FlashcardRepositoryProtocol) {
        self.flashcardRepository = flashcardRepository
    }

    public func execute(flashcard: Flashcard) async throws -> Flashcard {
        guard !flashcard.front.isEmpty else {
            throw AppError.invalidData("Flashcard front cannot be empty")
        }

        guard !flashcard.back.isEmpty else {
            throw AppError.invalidData("Flashcard back cannot be empty")
        }

        return try await flashcardRepository.createFlashcard(flashcard)
    }
}
