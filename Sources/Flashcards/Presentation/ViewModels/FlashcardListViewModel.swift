import Combine
import Core
import Foundation

/// ViewModel for flashcard list
@MainActor
public final class FlashcardListViewModel: ObservableObject {
    @Published public var flashcards: [Flashcard] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let getFlashcardsUseCase: GetFlashcardsUseCase
    private let updateFlashcardUseCase: UpdateFlashcardUseCase
    private let createFlashcardUseCase: CreateFlashcardUseCase
    private let classId: String
    private let userId: String

    public init(
        getFlashcardsUseCase: GetFlashcardsUseCase,
        updateFlashcardUseCase: UpdateFlashcardUseCase,
        createFlashcardUseCase: CreateFlashcardUseCase,
        classId: String,
        userId: String
    ) {
        self.getFlashcardsUseCase = getFlashcardsUseCase
        self.updateFlashcardUseCase = updateFlashcardUseCase
        self.createFlashcardUseCase = createFlashcardUseCase
        self.classId = classId
        self.userId = userId
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

    public func createFlashcard(front: String, back: String) async {
        guard !front.isEmpty, !back.isEmpty else { return }

        do {
            let flashcard = Flashcard(
                id: UUID().uuidString,
                classId: classId,
                userId: userId,
                front: front,
                back: back,
                noteIds: [],
                lastReviewedAt: nil,
                createdAt: Date(),
                updatedAt: Date()
            )

            let created = try await createFlashcardUseCase.execute(flashcard: flashcard)
            flashcards.append(created)
        } catch {
            errorMessage = "Failed to create flashcard"
        }
    }
}
