import Combine
import Core
import Foundation

/// Mock implementation of FlashcardRepository for development and testing
public final class MockFlashcardRepositoryImpl: FlashcardRepositoryProtocol {
    private var flashcards: [String: Flashcard] = [:]
    private let flashcardsSubject = CurrentValueSubject<[Flashcard], Never>([])
    private let changesSubject = PassthroughSubject<DataChange<Flashcard>, Never>()
    private var isObserving = false

    public init() {}

    public func getFlashcards(for classId: String) async throws -> [Flashcard] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        return flashcards.values.filter { $0.classId == classId }
    }

    public func getFlashcard(by id: String) async throws -> Flashcard {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let flashcard = flashcards[id] else {
            throw AppError.notFound("Flashcard not found")
        }

        return flashcard
    }

    public func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        flashcards[flashcard.id] = flashcard

        if isObserving {
            changesSubject.send(DataChange(type: .added, item: flashcard))
            updateFlashcardsSubject()
        }

        return flashcard
    }

    public func createFlashcards(_ flashcardList: [Flashcard]) async throws -> [Flashcard] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        for flashcard in flashcardList {
            flashcards[flashcard.id] = flashcard

            if isObserving {
                changesSubject.send(DataChange(type: .added, item: flashcard))
            }
        }

        if isObserving {
            updateFlashcardsSubject()
        }

        return flashcardList
    }

    public func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard flashcards[flashcard.id] != nil else {
            throw AppError.notFound("Flashcard not found")
        }

        var updatedFlashcard = flashcard
        updatedFlashcard.updatedAt = Date()
        flashcards[flashcard.id] = updatedFlashcard

        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: updatedFlashcard))
            updateFlashcardsSubject()
        }

        return updatedFlashcard
    }

    public func deleteFlashcard(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let deletedFlashcard = flashcards[id] else {
            throw AppError.notFound("Flashcard not found")
        }

        flashcards.removeValue(forKey: id)

        if isObserving {
            changesSubject.send(DataChange(type: .removed, item: deletedFlashcard))
            updateFlashcardsSubject()
        }
    }

    // MARK: - Real-time listeners

    public func observeFlashcards(for classId: String) -> AnyPublisher<[Flashcard], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialFlashcards = try await getFlashcards(for: classId)
                flashcardsSubject.send(initialFlashcards)
            } catch {
                flashcardsSubject.send([])
            }
        }
        return flashcardsSubject.eraseToAnyPublisher()
    }

    public func observeFlashcardChanges(for classId: String) -> AnyPublisher<
        DataChange<Flashcard>, Never
    > {
        isObserving = true
        return
            changesSubject
            .filter { $0.item.classId == classId }
            .eraseToAnyPublisher()
    }

    public func stopObserving() {
        isObserving = false
    }

    // MARK: - Private helpers

    private func updateFlashcardsSubject() {
        let allFlashcards = Array(flashcards.values)
        flashcardsSubject.send(allFlashcards)
    }
}
