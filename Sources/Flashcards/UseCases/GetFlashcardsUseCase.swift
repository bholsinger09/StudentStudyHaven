import Foundation
import Core

/// Use case for getting flashcards for a class
public final class GetFlashcardsUseCase {
    private let flashcardRepository: FlashcardRepositoryProtocol
    
    public init(flashcardRepository: FlashcardRepositoryProtocol) {
        self.flashcardRepository = flashcardRepository
    }
    
    public func execute(classId: UUID) async throws -> [Flashcard] {
        return try await flashcardRepository.getFlashcards(for: classId)
    }
}
