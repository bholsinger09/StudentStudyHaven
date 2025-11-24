import Foundation
import Core
import Combine

/// ViewModel for flashcard list
@MainActor
public final class FlashcardListViewModel: ObservableObject {
    @Published public var flashcards: [Flashcard] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let getFlashcardsUseCase: GetFlashcardsUseCase
    private let updateFlashcardUseCase: UpdateFlashcardUseCase
    private let classId: UUID
    
    public init(
        getFlashcardsUseCase: GetFlashcardsUseCase,
        updateFlashcardUseCase: UpdateFlashcardUseCase,
        classId: UUID
    ) {
        self.getFlashcardsUseCase = getFlashcardsUseCase
        self.updateFlashcardUseCase = updateFlashcardUseCase
        self.classId = classId
    }
    
    public func loadFlashcards() async {
        isLoading = true
        errorMessage = nil
        
        do {
            flashcards = try await getFlashcardsUseCase.execute(classId: classId)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load flashcards"
        }
        
        isLoading = false
    }
    
    public func markAsReviewed(_ flashcard: Flashcard) async {
        var updated = flashcard
        updated.lastReviewedAt = Date()
        
        do {
            let result = try await updateFlashcardUseCase.execute(flashcard: updated)
            if let index = flashcards.firstIndex(where: { $0.id == result.id }) {
                flashcards[index] = result
            }
        } catch {
            errorMessage = "Failed to update flashcard"
        }
    }
}
