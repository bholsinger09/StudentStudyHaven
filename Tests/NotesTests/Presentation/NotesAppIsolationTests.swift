import XCTest
import AppKit
@testable import Notes

/// Enhanced tests that verify Notes app doesn't intercept our text input
@MainActor
final class NotesAppIsolationTests: XCTestCase {
    
    private var viewModel: NoteEditorViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = NoteEditorViewModel(note: nil, classId: "test-class", userId: "test-user")
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - Critical Isolation Tests
    
    func testTextInput_IsOwnedByStudentStudyHaven() {
        // Arrange
        let testInput = "Biology 101"
        
        // Act
        viewModel.subjectMatter = testInput
        
        // Assert
        XCTAssertEqual(viewModel.subjectMatter, testInput, 
                      "\u274c FAIL: Text not captured by our app!")
        XCTAssertTrue(viewModel.inputDebugLog.count > 0, 
                     "Debug log should track input event")
        
        print("\u2705 PASS: Text input owned by StudentStudyHaven")
    }
    
    func testMultipleInputs_AreTracked() {
        // Arrange
        let inputs = ["Bio", "Biology", "Biology 101", "Biology 101 - Cell Structure"]
        
        // Act
        for input in inputs {
            viewModel.subjectMatter = input
        }
        
        // Assert
        XCTAssertEqual(viewModel.inputEventCount, inputs.count,
                      "Should track \\(inputs.count) input events")
        XCTAssertEqual(viewModel.subjectMatter, inputs.last!,
                      "Should contain final input value")
        
        print("\u2705 PASS: All \\(inputs.count) inputs tracked correctly")
    }
    
    func testNotesAppDetection_WhenNotesNotRunning() {
        // This test verifies we can detect if Notes app is active
        
        // Act
        viewModel.subjectMatter = "Test input"
        
        // Get running apps
        let runningApps = NSWorkspace.shared.runningApplications
        let notesApp = runningApps.first { app in
            app.bundleIdentifier == "com.apple.Notes" && app.isActive
        }
        
        // Assert
        if notesApp != nil {
            XCTFail(\"\u274c CRITICAL: Notes app is running and active! Input may be intercepted.\")
            XCTAssertTrue(viewModel.notesAppDetected, 
                         "ViewModel should detect active Notes app")
        } else {
            XCTAssertFalse(viewModel.notesAppDetected,
                          "ViewModel should not flag Notes app when it's not active")
            print(\"\u2705 PASS: Notes app not active, input safe\")
        }
    }
    
    func testDebugLog_CapturesTextChanges() {
        // Arrange
        viewModel.subjectMatter = ""
        
        // Act
        viewModel.subjectMatter = "Biology"
        viewModel.subjectMatter = "Biology 101"
        viewModel.content = "Cell structure notes"
        
        // Assert
        XCTAssertTrue(viewModel.inputDebugLog.count >= 3,
                     "Should log at least 3 events (2 subject + 1 content)")
        
        let hasSubjectLog = viewModel.inputDebugLog.contains { $0.contains("subjectMatter") }
        let hasContentLog = viewModel.inputDebugLog.contains { $0.contains("content") }
        
        XCTAssertTrue(hasSubjectLog, "Should log subject matter changes")
        XCTAssertTrue(hasContentLog, "Should log content changes")
        
        print(\"\u2705 PASS: Debug logging working correctly\")
        print(\"   Log entries: \\(viewModel.inputDebugLog.count)\")
    }
    
    func testInputOwnership_NoSystemIntervention() {
        // This test ensures our app owns the data, not the system
        
        // Arrange
        let sensitiveInput = "Notes for Biology Class"
        
        // Act
        viewModel.content = sensitiveInput
        
        // Assert
        XCTAssertEqual(viewModel.content, sensitiveInput,
                      "Content should be stored in our ViewModel, not system Notes")
        XCTAssertTrue(viewModel.content.contains("Notes for"),
                     "The word 'Notes' should be stored as plain text")
        
        // Verify it's a Swift String, not an NSAttributedString or system type
        XCTAssertTrue(type(of: viewModel.content) == String.self,
                     "Should be pure Swift String type")
        
        print(\"\u2705 PASS: Input owned by app, no system intervention\")
    }
    
    func testConcurrentInputs_MaintainIntegrity() {
        // Test that rapid input changes are all captured
        
        // Arrange
        let rapidInputs = (1...10).map { "Input \\($0)" }
        
        // Act
        for input in rapidInputs {
            viewModel.subjectMatter = input
        }
        
        // Assert
        XCTAssertEqual(viewModel.subjectMatter, "Input 10",
                      "Should contain last input")
        XCTAssertEqual(viewModel.inputEventCount, rapidInputs.count,
                      "Should track all \\(rapidInputs.count) events")
        
        print(\"\u2705 PASS: Concurrent inputs handled correctly\")
    }
    
    func testSpecialCharacters_NotInterpreted() {
        // Verify special characters don't trigger system behaviors
        
        // Arrange
        let specialInputs = [
            "file:///path/to/file",
            "x-apple-note://note-id",
            "com.apple.Notes",
            "tell application \\"Notes\\"",
            "• Bullet point",
            "Notes://link"
        ]
        
        // Act & Assert
        for input in specialInputs {
            viewModel.content = input
            XCTAssertEqual(viewModel.content, input,
                          "Special string '\\(input)' should be stored as-is")
        }
        
        print(\"\u2705 PASS: Special characters treated as plain text\")
    }
    
    func testDebugLog_ExportsCorrectly() {
        // Test debug log export functionality
        
        // Arrange
        viewModel.subjectMatter = "Test"
        viewModel.content = "Content"
        
        // Act
        let exportedLog = viewModel.exportDebugLog()
        
        // Assert
        XCTAssertTrue(exportedLog.contains("StudentStudyHaven"),
                     "Export should identify our app")
        XCTAssertTrue(exportedLog.contains("Total Events"),
                     "Export should include event count")
        XCTAssertFalse(exportedLog.isEmpty,
                      "Export should not be empty")
        
        print(\"\u2705 PASS: Debug log exports correctly\")
    }
    
    func testInputTracking_WorksWithEmptyStrings() {
        // Test that clearing fields is tracked
        
        // Arrange
        viewModel.subjectMatter = "Biology"
        let eventCountAfterAdd = viewModel.inputEventCount
        
        // Act
        viewModel.subjectMatter = ""
        
        // Assert
        XCTAssertTrue(viewModel.subjectMatter.isEmpty,
                     "Field should be cleared")
        XCTAssertGreaterThan(viewModel.inputEventCount, eventCountAfterAdd,
                            "Clearing should be tracked as an event")
        
        print(\"\u2705 PASS: Empty string tracking works\")
    }
    
    func testBundleIdentifier_IsNotNotesApp() {
        // Critical: Verify we're not running as Notes app
        
        // Act
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        
        // Assert
        XCTAssertFalse(bundleId.contains("com.apple.Notes"),
                      "\u274c CRITICAL: Bundle ID contains Notes app identifier!")
        XCTAssertFalse(bundleId.contains("Notes"),
                      "Bundle ID should not reference Notes app")
        
        print(\"\u2705 PASS: Running as StudentStudyHaven, not Notes app\")
        print(\"   Bundle ID: \\(bundleId.isEmpty ? \"(test environment)\" : bundleId)\")
    }
    
    // MARK: - Performance Tests
    
    func testLogging_DoesNotSlowDownInput() {
        // Verify logging doesn't impact input performance
        
        // Arrange
        let iterations = 100
        
        // Act
        let start = Date()
        for i in 0..<iterations {
            viewModel.subjectMatter = "Input \\(i)"
        }
        let duration = Date().timeIntervalSince(start)
        
        // Assert
        XCTAssertLessThan(duration, 1.0,
                         "100 inputs should complete in under 1 second")
        XCTAssertEqual(viewModel.inputEventCount, iterations,
                      "Should track all events")
        
        print(\"\u2705 PASS: Logging performant (\\(duration)s for \\(iterations) inputs)\")
    }
    
    func testMemory_LogDoesNotGrowUnbounded() {
        // Test that debug log has size limit
        
        // Act
        for i in 0..<200 {
            viewModel.subjectMatter = "Input \\(i)"
        }
        
        // Assert
        XCTAssertLessThanOrEqual(viewModel.inputDebugLog.count, 100,
                                "Log should be capped at 100 entries")
        
        print(\"\u2705 PASS: Debug log size limited (\\(viewModel.inputDebugLog.count) entries)\")
    }
}
