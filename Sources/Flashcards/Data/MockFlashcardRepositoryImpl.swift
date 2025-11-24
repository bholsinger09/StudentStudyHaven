import Foundation
import Core

/// Mock implementation of FlashcardRepository for development and testing
public final class MockFlashcardRepositoryImpl: FlashcardRepositoryProtocol {
    private var flashcards: [UUID: Flashcard] = [:]
    
    public init() {}
    
    public func getFlashcards(for classId: UUID) async throws -> [Flashcard] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return flashcards.values.filter { $0.classId == classId }
    }
    
    public func getFlashcard(by id: UUID) async throws -> Flashcard {
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
        return flashcard
    }
    
    public func createFlashcards(_ flashcardList: [Flashcard]) async throws -> [Flashcard] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        for flashcard in flashcardList {
            flashcards[flashcard.id] = flashcard
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
        return updatedFlashcard
    }
    
    public func deleteFlashcard(id: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard flashcards[id] != nil else {
            throw AppError.notFound("Flashcard not found")
        }
        
        flashcards.removeValue(forKey: id)
    }
}
