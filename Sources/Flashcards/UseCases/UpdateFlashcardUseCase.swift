import Foundation
import Core

/// Use case for updating a flashcard review status
public final class UpdateFlashcardUseCase {
    private let flashcardRepository: FlashcardRepositoryProtocol
    
    public init(flashcardRepository: FlashcardRepositoryProtocol) {
        self.flashcardRepository = flashcardRepository
    }
    
    public func execute(flashcard: Flashcard) async throws -> Flashcard {
        return try await flashcardRepository.updateFlashcard(flashcard)
    }
}
