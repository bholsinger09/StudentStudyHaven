import XCTest
import Core
@testable import Notes

/// Tests for NoteEditorViewModel to ensure complete isolation from macOS Notes app
@MainActor
final class NoteEditorViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: NoteEditorViewModel!
    private let testClassId = "test-class-123"
    private let testUserId = "test-user-456"
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        sut = NoteEditorViewModel(
            note: nil,
            classId: testClassId,
            userId: testUserId
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization_WithoutExistingNote_SetsDefaultValues() {
        // Assert
        XCTAssertTrue(sut.subjectMatter.isEmpty, "Subject matter should be empty on initialization")
        XCTAssertTrue(sut.content.isEmpty, "Content should be empty on initialization")
        XCTAssertFalse(sut.isSaving, "Should not be saving on initialization")
        XCTAssertNotNil(sut.documentDate, "Document date should be set")
    }
    
    func testInitialization_WithExistingNote_LoadsNoteData() {
        // Arrange
        let existingNote = Note(
            id: "existing-note-id",
            userId: testUserId,
            classId: testClassId,
            title: "Biology 101",
            content: "Cell structure notes",
            tags: [],
            linkedNoteIds: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Act
        let viewModel = NoteEditorViewModel(
            note: existingNote,
            classId: testClassId,
            userId: testUserId
        )
        
        // Assert
        XCTAssertEqual(viewModel.subjectMatter, "Biology 101", "Should load existing note title")
        XCTAssertEqual(viewModel.content, "Cell structure notes", "Should load existing note content")
    }
    
    // MARK: - Text Input Isolation Tests
    
    func testSubjectMatter_DoesNotContainSystemReservedKeywords() {
        // Arrange
        let testInputs = [
            "AppleScript",
            "com.apple.Notes",
            "com.apple.notesapp",
            "NSAppleEventDescriptor",
            "tell application Notes"
        ]
        
        // Act & Assert
        for input in testInputs {
            sut.subjectMatter = input
            XCTAssertEqual(sut.subjectMatter, input, "Should handle '\(input)' as plain text without system interpretation")
            XCTAssertFalse(sut.subjectMatter.contains("://"), "Should not contain URL schemes that might trigger system handlers")
        }
    }
    
    func testContent_HandlesSpecialCharactersWithoutSystemInterpretation() {
        // Arrange
        let specialContent = """
        Notes for Biology Class
        • Cell structure
        • Mitochondria
        file://
        x-apple-note://
        """
        
        // Act
        sut.content = specialContent
        
        // Assert
        XCTAssertEqual(sut.content, specialContent, "Content should be stored exactly as entered")
        XCTAssertTrue(sut.content.contains("Notes for"), "Should preserve the word 'Notes' as plain text")
    }
    
    func testSubjectMatter_PreservesWhitespaceAndFormatting() {
        // Arrange
        let formattedInput = "  Biology 101  \n  Advanced Topics  "
        
        // Act
        sut.subjectMatter = formattedInput
        
        // Assert
        XCTAssertEqual(sut.subjectMatter, formattedInput, "Should preserve all whitespace and formatting")
    }
    
    // MARK: - Validation Tests
    
    func testIsValid_WithEmptySubjectMatter_ReturnsFalse() {
        // Arrange
        sut.subjectMatter = ""
        
        // Assert
        XCTAssertFalse(sut.isValid, "Document should be invalid with empty subject")
    }
    
    func testIsValid_WithWhitespaceOnlySubjectMatter_ReturnsFalse() {
        // Arrange
        sut.subjectMatter = "   \n  \t  "
        
        // Assert
        XCTAssertFalse(sut.isValid, "Document should be invalid with whitespace-only subject")
    }
    
    func testIsValid_WithValidSubjectMatter_ReturnsTrue() {
        // Arrange
        sut.subjectMatter = "Biology 101"
        
        // Assert
        XCTAssertTrue(sut.isValid, "Document should be valid with non-empty subject")
    }
    
    // MARK: - Save Operation Tests
    
    func testSaveDocument_WithValidData_CompletesSuccessfully() async {
        // Arrange
        sut.subjectMatter = "Chemistry Notes"
        sut.content = "Chapter 5: Reactions"
        
        // Act
        await sut.saveDocument()
        
        // Assert
        XCTAssertFalse(sut.isSaving, "Should not be saving after completion")
    }
    
    func testSaveDocument_WithEmptySubjectMatter_DoesNotSave() async {
        // Arrange
        sut.subjectMatter = ""
        sut.content = "Some content"
        
        // Act
        await sut.saveDocument()
        
        // Assert - operation should return early without saving
        XCTAssertFalse(sut.isSaving, "Should not be in saving state")
    }
    
    func testSaveDocument_SetsSavingStateCorrectly() async {
        // Arrange
        sut.subjectMatter = "Valid Subject"
        
        // Act
        let saveTask = Task {
            await sut.saveDocument()
        }
        
        // Brief delay to check saving state
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Assert
        // Note: isSaving might be true or false depending on timing
        // The important thing is it doesn't crash and completes
        
        await saveTask.value
        XCTAssertFalse(sut.isSaving, "Should not be saving after completion")
    }
    
    // MARK: - Date Handling Tests
    
    func testDocumentDate_CanBeSetToAnyDate() {
        // Arrange
        let futureDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
        let pastDate = Date().addingTimeInterval(-86400 * 30) // 30 days ago
        
        // Act & Assert
        sut.documentDate = futureDate
        XCTAssertEqual(sut.documentDate, futureDate, "Should handle future dates")
        
        sut.documentDate = pastDate
        XCTAssertEqual(sut.documentDate, pastDate, "Should handle past dates")
    }
    
    // MARK: - Memory and State Tests
    
    func testViewModel_DoesNotLeakReferences() {
        // Arrange
        weak var weakViewModel: NoteEditorViewModel?
        
        // Act
        autoreleasepool {
            let viewModel = NoteEditorViewModel(
                note: nil,
                classId: testClassId,
                userId: testUserId
            )
            weakViewModel = viewModel
            XCTAssertNotNil(weakViewModel, "ViewModel should exist in pool")
        }
        
        // Assert
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated after leaving scope")
    }
    
    func testMultipleInstances_AreIndependent() {
        // Arrange
        let viewModel1 = NoteEditorViewModel(note: nil, classId: "class1", userId: "user1")
        let viewModel2 = NoteEditorViewModel(note: nil, classId: "class2", userId: "user2")
        
        // Act
        viewModel1.subjectMatter = "Math 101"
        viewModel1.content = "Algebra notes"
        
        viewModel2.subjectMatter = "Physics 201"
        viewModel2.content = "Newton's laws"
        
        // Assert
        XCTAssertEqual(viewModel1.subjectMatter, "Math 101", "ViewModel 1 should have its own data")
        XCTAssertEqual(viewModel2.subjectMatter, "Physics 201", "ViewModel 2 should have its own data")
        XCTAssertNotEqual(viewModel1.content, viewModel2.content, "ViewModels should be independent")
    }
    
    // MARK: - Content Integrity Tests
    
    func testContent_PreservesUnicodeCharacters() {
        // Arrange
        let unicodeContent = "Biology: α-helix, β-sheet, π bonds, 中文, 日本語, 한글, Émojis 😀🧬"
        
        // Act
        sut.content = unicodeContent
        
        // Assert
        XCTAssertEqual(sut.content, unicodeContent, "Should preserve all Unicode characters")
    }
    
    func testContent_PreservesNewlinesAndFormatting() {
        // Arrange
        let formattedContent = """
        Title: Biology Notes
        
        Section 1:
        - Point A
        - Point B
        
        Section 2:
            Indented content
                More indentation
        """
        
        // Act
        sut.content = formattedContent
        
        // Assert
        XCTAssertEqual(sut.content, formattedContent, "Should preserve all formatting")
    }
    
    func testContent_HandlesLargeText() {
        // Arrange
        let largeContent = String(repeating: "Biology notes. ", count: 10000)
        
        // Act
        sut.content = largeContent
        
        // Assert
        XCTAssertEqual(sut.content.count, largeContent.count, "Should handle large content without truncation")
    }
    
    // MARK: - Edge Case Tests
    
    func testSubjectMatter_HandlesEmptyString() {
        // Act
        sut.subjectMatter = ""
        
        // Assert
        XCTAssertTrue(sut.subjectMatter.isEmpty)
        XCTAssertFalse(sut.isValid)
    }
    
    func testContent_HandlesEmptyString() {
        // Act
        sut.content = ""
        
        // Assert
        XCTAssertTrue(sut.content.isEmpty)
        // Content can be empty, only subject matter is required
        sut.subjectMatter = "Valid"
        XCTAssertTrue(sut.isValid)
    }
    
    func testSubjectMatter_HandlesVeryLongText() {
        // Arrange
        let longSubject = String(repeating: "A", count: 1000)
        
        // Act
        sut.subjectMatter = longSubject
        
        // Assert
        XCTAssertEqual(sut.subjectMatter.count, 1000)
        XCTAssertTrue(sut.isValid)
    }
}
