import XCTest
@testable import Notes
@testable import Core

final class LinkNotesUseCaseTests: XCTestCase {
    var mockRepository: MockNoteRepository!
    var sut: LinkNotesUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockNoteRepository()
        sut = LinkNotesUseCase(noteRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testLinkNotesSuccessfully() async throws {
        // Given
        let userId = UUID()
        let classId = UUID()
        let sourceNoteId = UUID()
        let targetNoteId = UUID()
        
        let sourceNote = Note(
            id: sourceNoteId,
            classId: classId,
            userId: userId,
            title: "Source Note",
            content: "Content"
        )
        
        let targetNote = Note(
            id: targetNoteId,
            classId: classId,
            userId: userId,
            title: "Target Note",
            content: "Content"
        )
        
        mockRepository.getNoteResult = .success(sourceNote)
        mockRepository.updateNoteResult = .success(sourceNote)
        
        // When
        let result = try await sut.execute(sourceNoteId: sourceNoteId, targetNoteId: targetNoteId)
        
        // Then
        XCTAssertEqual(mockRepository.getNoteCallCount, 2) // Once for source, once for target
        XCTAssertEqual(mockRepository.updateNoteCallCount, 1)
    }
    
    func testLinkNotesWithNonexistentTarget() async {
        // Given
        let userId = UUID()
        let classId = UUID()
        let sourceNoteId = UUID()
        let targetNoteId = UUID()
        
        let sourceNote = Note(
            id: sourceNoteId,
            classId: classId,
            userId: userId,
            title: "Source Note",
            content: "Content"
        )
        
        mockRepository.getNoteResult = .success(sourceNote)
        mockRepository.getNoteAlternateResult = .failure(AppError.notFound("Target note not found"))
        
        // When/Then
        do {
            _ = try await sut.execute(sourceNoteId: sourceNoteId, targetNoteId: targetNoteId)
            XCTFail("Should throw error for nonexistent target")
        } catch let error as AppError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Mock Repository
class MockNoteRepository: NoteRepositoryProtocol {
    var getNoteCallCount = 0
    var updateNoteCallCount = 0
    var getNoteResult: Result<Note, Error> = .failure(AppError.unknown("Not configured"))
    var getNoteAlternateResult: Result<Note, Error>?
    var updateNoteResult: Result<Note, Error> = .failure(AppError.unknown("Not configured"))
    
    func getNotes(for classId: UUID) async throws -> [Note] {
        return []
    }
    
    func getNote(by id: UUID) async throws -> Note {
        getNoteCallCount += 1
        if getNoteCallCount > 1, let alternate = getNoteAlternateResult {
            return try alternate.get()
        }
        return try getNoteResult.get()
    }
    
    func getLinkedNotes(for noteId: UUID) async throws -> [Note] {
        return []
    }
    
    func createNote(_ note: Note) async throws -> Note {
        return note
    }
    
    func updateNote(_ note: Note) async throws -> Note {
        updateNoteCallCount += 1
        return try updateNoteResult.get()
    }
    
    func deleteNote(id: UUID) async throws {
    }
    
    func searchNotes(query: String, classId: UUID?) async throws -> [Note] {
        return []
    }
}
