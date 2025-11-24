import XCTest
@testable import Flashcards
@testable import Core

final class GenerateFlashcardsUseCaseTests: XCTestCase {
    var mockRepository: MockFlashcardRepository!
    var sut: GenerateFlashcardsUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockFlashcardRepository()
        sut = GenerateFlashcardsUseCase(flashcardRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testGenerateFlashcardsFromNoteWithDefinitions() async throws {
        // Given
        let userId = UUID()
        let classId = UUID()
        let note = Note(
            classId: classId,
            userId: userId,
            title: "Computer Science Basics",
            content: "Algorithm is a step-by-step procedure for solving a problem. Data Structure: A way of organizing data."
        )
        
        mockRepository.createFlashcardsResult = .success([
            Flashcard(classId: classId, userId: userId, front: "Algorithm", back: "a step-by-step procedure for solving a problem", noteIds: [note.id]),
            Flashcard(classId: classId, userId: userId, front: "Data Structure", back: "A way of organizing data", noteIds: [note.id])
        ])
        
        // When
        let flashcards = try await sut.execute(from: note, userId: userId)
        
        // Then
        XCTAssertEqual(flashcards.count, 2)
        XCTAssertEqual(mockRepository.createFlashcardsCallCount, 1)
        XCTAssertTrue(flashcards.contains { $0.front == "Algorithm" })
    }
    
    func testGenerateFlashcardsFromEmptyContent() async {
        // Given
        let userId = UUID()
        let classId = UUID()
        let note = Note(
            classId: classId,
            userId: userId,
            title: "Empty Note",
            content: "Just some random text without definitions."
        )
        
        // When/Then
        do {
            _ = try await sut.execute(from: note, userId: userId)
            XCTFail("Should throw error when no flashcards can be generated")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("generate"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Mock Repository
class MockFlashcardRepository: FlashcardRepositoryProtocol {
    var createFlashcardsCallCount = 0
    var createFlashcardsResult: Result<[Flashcard], Error> = .failure(AppError.unknown("Not configured"))
    
    func getFlashcards(for classId: UUID) async throws -> [Flashcard] {
        return []
    }
    
    func getFlashcard(by id: UUID) async throws -> Flashcard {
        throw AppError.notFound("Flashcard not found")
    }
    
    func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        return flashcard
    }
    
    func createFlashcards(_ flashcards: [Flashcard]) async throws -> [Flashcard] {
        createFlashcardsCallCount += 1
        return try createFlashcardsResult.get()
    }
    
    func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard {
        return flashcard
    }
    
    func deleteFlashcard(id: UUID) async throws {
    }
}
