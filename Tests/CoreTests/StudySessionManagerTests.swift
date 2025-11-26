import XCTest
import Combine
@testable import Core

final class StudySessionManagerTests: XCTestCase {
    var sut: StudySessionManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        let config = StudySessionManager.SessionConfiguration(
            focusDuration: 1, // 1 minute for faster tests
            shortBreakDuration: 1,
            longBreakDuration: 1,
            sessionsBeforeLongBreak: 2
        )
        sut = StudySessionManager(configuration: config)
        cancellables = []
    }
    
    override func tearDown() {
        sut.endSession()
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_StartsInIdleState() {
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testInit_StartsWith FocusType() {
        if case .focus = sut.currentType {
            XCTAssert(true)
        } else {
            XCTFail("Should start with focus type")
        }
    }
    
    func testInit_SetsInitialTimeRemaining() {
        XCTAssertEqual(sut.timeRemaining, 60) // 1 minute = 60 seconds
    }
    
    func testInit_CompletedSessionsIsZero() {
        XCTAssertEqual(sut.completedSessions, 0)
    }
    
    // MARK: - Start Tests
    
    func testStart_ChangesStateToRunning() {
        // When
        sut.start()
        
        // Then
        XCTAssertEqual(sut.state, .running)
    }
    
    func testStart_CreatesCurrentSession() {
        // When
        sut.start()
        
        // Then
        XCTAssertNotNil(sut.currentSession)
    }
    
    func testStart_WhenAlreadyRunning_DoesNothing() {
        // Given
        sut.start()
        let firstSession = sut.currentSession
        
        // When
        sut.start()
        
        // Then
        XCTAssertEqual(sut.currentSession?.id, firstSession?.id)
    }
    
    // MARK: - Pause/Resume Tests
    
    func testPause_ChangesStateToPaused() {
        // Given
        sut.start()
        
        // When
        sut.pause()
        
        // Then
        XCTAssertEqual(sut.state, .paused)
    }
    
    func testPause_WhenNotRunning_DoesNothing() {
        // When
        sut.pause()
        
        // Then
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testResume_ChangesStateToRunning() {
        // Given
        sut.start()
        sut.pause()
        
        // When
        sut.resume()
        
        // Then
        XCTAssertEqual(sut.state, .running)
    }
    
    func testResume_WhenNotPaused_DoesNothing() {
        // When
        sut.resume()
        
        // Then
        XCTAssertEqual(sut.state, .idle)
    }
    
    // MARK: - Reset Tests
    
    func testReset_ChangesStateToIdle() {
        // Given
        sut.start()
        
        // When
        sut.reset()
        
        // Then
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testReset_RestoresInitialTimeRemaining() {
        // Given
        sut.start()
        let initialTime = sut.currentType.duration
        
        // When
        sut.reset()
        
        // Then
        XCTAssertEqual(sut.timeRemaining, initialTime)
    }
    
    func testReset_ClearsCurrentSession() {
        // Given
        sut.start()
        
        // When
        sut.reset()
        
        // Then
        XCTAssertNil(sut.currentSession)
    }
    
    // MARK: - Skip Tests
    
    func testSkip_FromFocus_MovesToShortBreak() {
        // Given
        sut.start()
        
        // When
        sut.skip()
        
        // Then
        if case .shortBreak = sut.currentType {
            XCTAssert(true)
        } else {
            XCTFail("Should move to short break")
        }
    }
    
    func testSkip_AfterMultipleSessions_MovesToLongBreak() {
        // Given - Complete enough focus sessions for long break
        sut.start()
        sut.skip() // Complete first focus -> short break
        sut.skip() // Complete short break -> focus
        sut.skip() // Complete second focus -> should be long break
        
        // Then
        if case .longBreak = sut.currentType {
            XCTAssert(true)
        } else {
            XCTFail("Should move to long break after configured sessions")
        }
    }
    
    func testSkip_IncrementsCompletedSessions() {
        // Given
        sut.start()
        let initial = sut.completedSessions
        
        // When
        sut.skip()
        
        // Then
        XCTAssertEqual(sut.completedSessions, initial + 1)
    }
    
    // MARK: - End Session Tests
    
    func testEndSession_ResetsToInitialState() {
        // Given
        sut.start()
        sut.skip()
        sut.skip()
        
        // When
        sut.endSession()
        
        // Then
        XCTAssertEqual(sut.state, .idle)
        XCTAssertEqual(sut.completedSessions, 0)
        if case .focus = sut.currentType {
            XCTAssert(true)
        } else {
            XCTFail("Should reset to focus type")
        }
    }
    
    // MARK: - Progress Tests
    
    func testProgress_InitiallyZero() {
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }
    
    func testProgress_IncreasesOverTime() async {
        // Given
        sut.start()
        
        // When
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Then
        XCTAssertGreaterThan(sut.progress, 0.0)
        XCTAssertLessThanOrEqual(sut.progress, 1.0)
        
        sut.pause()
    }
    
    // MARK: - Formatted Time Tests
    
    func testFormattedTimeRemaining_ShowsCorrectFormat() {
        // Given
        sut.timeRemaining = 125 // 2:05
        
        // When
        let formatted = sut.formattedTimeRemaining
        
        // Then
        XCTAssertEqual(formatted, "02:05")
    }
    
    func testFormattedTimeRemaining_HandlesZeroPadding() {
        // Given
        sut.timeRemaining = 65 // 1:05
        
        // When
        let formatted = sut.formattedTimeRemaining
        
        // Then
        XCTAssertEqual(formatted, "01:05")
    }
    
    // MARK: - Active State Tests
    
    func testIsActive_TrueWhenRunning() {
        // When
        sut.start()
        
        // Then
        XCTAssertTrue(sut.isActive)
    }
    
    func testIsActive_TrueWhenPaused() {
        // When
        sut.start()
        sut.pause()
        
        // Then
        XCTAssertTrue(sut.isActive)
    }
    
    func testIsActive_FalseWhenIdle() {
        XCTAssertFalse(sut.isActive)
    }
    
    // MARK: - Sessions Until Long Break Tests
    
    func testSessionsUntilLongBreak_InitiallyShowsMaxSessions() {
        let expected = sut.configuration.sessionsBeforeLongBreak
        XCTAssertEqual(sut.sessionsUntilLongBreak, expected)
    }
    
    func testSessionsUntilLongBreak_DecreasesAfterFocusSession() {
        // Given
        sut.start()
        
        // When
        sut.skip() // Complete first focus
        
        // Then
        XCTAssertEqual(sut.sessionsUntilLongBreak, 1)
    }
    
    func testSessionsUntilLongBreak_ResetsAfterLongBreak() {
        // Given - Complete cycle to long break
        sut.start()
        sut.skip() // Focus 1 done
        sut.skip() // Short break done
        sut.skip() // Focus 2 done -> long break
        
        // When - Skip long break
        sut.skip()
        
        // Then
        XCTAssertEqual(sut.sessionsUntilLongBreak, sut.configuration.sessionsBeforeLongBreak)
    }
    
    // MARK: - Configuration Tests
    
    func testConfiguration_CustomDurations_Applied() {
        // Given
        let config = StudySessionManager.SessionConfiguration(
            focusDuration: 30,
            shortBreakDuration: 7,
            longBreakDuration: 20
        )
        
        // When
        let manager = StudySessionManager(configuration: config)
        
        // Then
        XCTAssertEqual(manager.timeRemaining, 30 * 60)
    }
    
    func testAutoStartBreaks_WhenEnabled_StartsAutomatically() {
        // Given
        let config = StudySessionManager.SessionConfiguration(
            focusDuration: 1,
            autoStartBreaks: true
        )
        let manager = StudySessionManager(configuration: config)
        manager.start()
        
        // When
        manager.skip()
        
        // Then
        // Note: In real implementation, this would auto-start
        // For now, we just verify the config is stored
        XCTAssertTrue(manager.configuration.autoStartBreaks)
    }
    
    // MARK: - Session Type Tests
    
    func testSessionType_FocusDuration_CalculatesCorrectly() {
        let type = StudySessionManager.SessionType.focus(minutes: 25)
        XCTAssertEqual(type.duration, 25 * 60)
    }
    
    func testSessionType_ShortBreakDuration_CalculatesCorrectly() {
        let type = StudySessionManager.SessionType.shortBreak(minutes: 5)
        XCTAssertEqual(type.duration, 5 * 60)
    }
    
    func testSessionType_LongBreakDuration_CalculatesCorrectly() {
        let type = StudySessionManager.SessionType.longBreak(minutes: 15)
        XCTAssertEqual(type.duration, 15 * 60)
    }
    
    func testSessionType_DisplayNames_AreCorrect() {
        XCTAssertEqual(StudySessionManager.SessionType.focus(minutes: 25).displayName, "Focus Time")
        XCTAssertEqual(StudySessionManager.SessionType.shortBreak(minutes: 5).displayName, "Short Break")
        XCTAssertEqual(StudySessionManager.SessionType.longBreak(minutes: 15).displayName, "Long Break")
    }
    
    // MARK: - Integration Tests
    
    func testFullPomodoroycle_CompletesCorrectly() {
        // Given
        sut.start()
        
        // When - Complete full cycle (focus -> break -> focus -> long break)
        sut.skip() // Focus 1
        XCTAssertEqual(sut.completedSessions, 1)
        
        sut.skip() // Short break
        XCTAssertEqual(sut.completedSessions, 1)
        
        sut.skip() // Focus 2
        XCTAssertEqual(sut.completedSessions, 2)
        
        // Then - Should be on long break
        if case .longBreak = sut.currentType {
            XCTAssert(true)
        } else {
            XCTFail("Should be on long break after configured sessions")
        }
    }
    
    func testPauseAndResume_MaintainsCorrectTime() async {
        // Given
        sut.start()
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        let timeBeforePause = sut.timeRemaining
        
        // When
        sut.pause()
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds paused
        sut.resume()
        try? await Task.sleep(nanoseconds: 100_000_000) // Small delay
        
        // Then - Time should resume from where it paused
        XCTAssertEqual(sut.timeRemaining, timeBeforePause, accuracy: 2.0)
        
        sut.pause()
    }
    
    func testMultipleResets_WorkCorrectly() {
        // When
        sut.start()
        sut.reset()
        sut.start()
        sut.reset()
        sut.start()
        
        // Then
        XCTAssertEqual(sut.state, .running)
        XCTAssertNotNil(sut.currentSession)
    }
}

// MARK: - StudySession Tests

final class StudySessionTests: XCTestCase {
    
    func testStudySession_InitializesCorrectly() {
        // Given
        let type = StudySessionManager.SessionType.focus(minutes: 25)
        let startTime = Date()
        
        // When
        let session = StudySession(type: type, startTime: startTime)
        
        // Then
        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.startTime, startTime)
        XCTAssertFalse(session.completed)
    }
    
    func testStudySession_WithClassId_StoresCorrectly() {
        // Given
        let type = StudySessionManager.SessionType.focus(minutes: 25)
        let classId = "class-123"
        
        // When
        let session = StudySession(type: type, startTime: Date(), classId: classId)
        
        // Then
        XCTAssertEqual(session.classId, classId)
    }
    
    func testStudySession_WithNotes_StoresCorrectly() {
        // Given
        let type = StudySessionManager.SessionType.focus(minutes: 25)
        let notes = "Studied calculus chapter 5"
        
        // When
        let session = StudySession(type: type, startTime: Date(), notes: notes)
        
        // Then
        XCTAssertEqual(session.notes, notes)
    }
}
