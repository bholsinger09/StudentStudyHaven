import XCTest

@testable import Core

final class StatisticsTests: XCTestCase {

    // MARK: - StudyStatistics Tests

    func testFormattedStudyTime_WithHours_ShowsHoursAndMinutes() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.totalStudyTime = 3665  // 1 hour, 1 minute, 5 seconds

        // When
        let formatted = stats.formattedStudyTime

        // Then
        XCTAssertEqual(formatted, "1h 1m")
    }

    func testFormattedStudyTime_WithoutHours_ShowsMinutesOnly() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.totalStudyTime = 300  // 5 minutes

        // When
        let formatted = stats.formattedStudyTime

        // Then
        XCTAssertEqual(formatted, "5m")
    }

    func testAverageSessionDuration_CalculatesCorrectly() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.totalStudyTime = 3000  // 50 minutes
        stats.totalSessions = 2

        // When
        let average = stats.averageSessionDuration

        // Then
        XCTAssertEqual(average, 1500, accuracy: 0.1)  // 25 minutes per session
    }

    func testAverageSessionDuration_WithNoSessions_ReturnsZero() {
        // Given
        let stats = StudyStatistics(userId: "user-1")

        // When
        let average = stats.averageSessionDuration

        // Then
        XCTAssertEqual(average, 0)
    }

    func testFormattedAccuracy_ShowsPercentage() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.flashcardAccuracy = 0.856

        // When
        let formatted = stats.formattedAccuracy

        // Then
        XCTAssertEqual(formatted, "85.6%")
    }
}

final class GoalTests: XCTestCase {

    func testProgress_CalculatesCorrectly() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Study 10 hours",
            description: "Reach 10 hours of study time",
            type: .studyTime,
            target: 600,  // 10 hours in minutes
            current: 300  // 5 hours
        )

        // When
        let progress = goal.progress

        // Then
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }

    func testProgress_WithZeroTarget_ReturnsZero() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 0,
            current: 10
        )

        // When
        let progress = goal.progress

        // Then
        XCTAssertEqual(progress, 0)
    }

    func testProgress_CapsAtOne() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 150
        )

        // When
        let progress = goal.progress

        // Then
        XCTAssertEqual(progress, 1.0)
    }

    func testFormattedProgress_ShowsPercentage() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 75
        )

        // When
        let formatted = goal.formattedProgress

        // Then
        XCTAssertEqual(formatted, "75%")
    }

    func testIsOverdue_WithPastDeadline_ReturnsTrue() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 50,
            deadline: pastDate
        )

        // When/Then
        XCTAssertTrue(goal.isOverdue)
    }

    func testIsOverdue_WithFutureDeadline_ReturnsFalse() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 50,
            deadline: futureDate
        )

        // When/Then
        XCTAssertFalse(goal.isOverdue)
    }

    func testIsOverdue_WhenCompleted_ReturnsFalse() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 100,
            deadline: pastDate,
            completed: true
        )

        // When/Then
        XCTAssertFalse(goal.isOverdue)
    }
}

final class GoalTypeTests: XCTestCase {

    func testDisplayNames_AreCorrect() {
        XCTAssertEqual(GoalType.studyTime.displayName, "Study Time")
        XCTAssertEqual(GoalType.flashcards.displayName, "Flashcards")
        XCTAssertEqual(GoalType.notes.displayName, "Notes")
        XCTAssertEqual(GoalType.streak.displayName, "Study Streak")
        XCTAssertEqual(GoalType.sessions.displayName, "Study Sessions")
        XCTAssertEqual(GoalType.classes.displayName, "Classes")
    }

    func testUnits_AreCorrect() {
        XCTAssertEqual(GoalType.studyTime.unit, "minutes")
        XCTAssertEqual(GoalType.flashcards.unit, "flashcards")
        XCTAssertEqual(GoalType.notes.unit, "notes")
        XCTAssertEqual(GoalType.streak.unit, "days")
    }

    func testIcons_AreSet() {
        XCTAssertFalse(GoalType.studyTime.icon.isEmpty)
        XCTAssertFalse(GoalType.flashcards.icon.isEmpty)
        XCTAssertFalse(GoalType.notes.icon.isEmpty)
    }
}

final class AchievementTests: XCTestCase {

    func testIsUnlocked_WithUnlockedDate_ReturnsTrue() {
        // Given
        let achievement = Achievement(
            title: "Test",
            description: "Test",
            category: .streak,
            requirement: 7,
            icon: "flame.fill",
            unlockedDate: Date()
        )

        // When/Then
        XCTAssertTrue(achievement.isUnlocked)
    }

    func testIsUnlocked_WithoutUnlockedDate_ReturnsFalse() {
        // Given
        let achievement = Achievement(
            title: "Test",
            description: "Test",
            category: .streak,
            requirement: 7,
            icon: "flame.fill"
        )

        // When/Then
        XCTAssertFalse(achievement.isUnlocked)
    }

    func testAllAchievements_ContainsMultipleAchievements() {
        XCTAssertGreaterThan(Achievement.allAchievements.count, 10)
    }

    func testAllAchievements_HasStreakAchievements() {
        let streakAchievements = Achievement.allAchievements.filter { $0.category == .streak }
        XCTAssertGreaterThan(streakAchievements.count, 0)
    }

    func testAllAchievements_HasStudyTimeAchievements() {
        let timeAchievements = Achievement.allAchievements.filter { $0.category == .studyTime }
        XCTAssertGreaterThan(timeAchievements.count, 0)
    }
}

final class ProgressTrackerTests: XCTestCase {
    var sut: ProgressTracker!

    override func setUp() {
        super.setUp()
        sut = ProgressTracker()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Update Statistics Tests

    func testUpdateStatistics_IncrementsTotalStudyTime() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        let duration: TimeInterval = 1500  // 25 minutes

        // When
        sut.updateStatistics(&stats, sessionDuration: duration)

        // Then
        XCTAssertEqual(stats.totalStudyTime, duration)
    }

    func testUpdateStatistics_IncrementsTotalSessions() {
        // Given
        var stats = StudyStatistics(userId: "user-1")

        // When
        sut.updateStatistics(&stats, sessionDuration: 1000)
        sut.updateStatistics(&stats, sessionDuration: 1000)

        // Then
        XCTAssertEqual(stats.totalSessions, 2)
    }

    func testUpdateStatistics_IncrementsTotalFlashcardsReviewed() {
        // Given
        var stats = StudyStatistics(userId: "user-1")

        // When
        sut.updateStatistics(&stats, sessionDuration: 1000, flashcardsReviewed: 10)

        // Then
        XCTAssertEqual(stats.totalFlashcardsReviewed, 10)
    }

    func testUpdateStatistics_CalculatesAccuracy() {
        // Given
        var stats = StudyStatistics(userId: "user-1")

        // When
        sut.updateStatistics(
            &stats, sessionDuration: 1000, flashcardsReviewed: 10, correctFlashcards: 8)

        // Then
        XCTAssertEqual(stats.flashcardAccuracy, 0.8, accuracy: 0.01)
    }

    func testUpdateStatistics_UpdatesAverageAccuracyOverMultipleSessions() {
        // Given
        var stats = StudyStatistics(userId: "user-1")

        // When
        sut.updateStatistics(
            &stats, sessionDuration: 1000, flashcardsReviewed: 10, correctFlashcards: 8)  // 80%
        sut.updateStatistics(
            &stats, sessionDuration: 1000, flashcardsReviewed: 10, correctFlashcards: 10)  // 100%

        // Then - Average should be 90%
        XCTAssertEqual(stats.flashcardAccuracy, 0.9, accuracy: 0.01)
    }

    func testUpdateStatistics_UpdatesLastStudyDate() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        let before = Date()

        // When
        sut.updateStatistics(&stats, sessionDuration: 1000)

        // Then
        XCTAssertNotNil(stats.lastStudyDate)
        XCTAssertGreaterThanOrEqual(stats.lastStudyDate!, before)
    }

    // MARK: - Update Streak Tests

    func testUpdateStreak_FirstStudy_SetsStreakToOne() {
        // Given
        var stats = StudyStatistics(userId: "user-1")

        // When
        sut.updateStreak(&stats)

        // Then
        XCTAssertEqual(stats.currentStreak, 1)
        XCTAssertEqual(stats.longestStreak, 1)
    }

    func testUpdateStreak_ConsecutiveDay_IncrementsStreak() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        stats.lastStudyDate = yesterday
        stats.currentStreak = 1
        stats.longestStreak = 1

        // When
        sut.updateStreak(&stats)

        // Then
        XCTAssertEqual(stats.currentStreak, 2)
        XCTAssertEqual(stats.longestStreak, 2)
    }

    func testUpdateStreak_SameDay_NoChange() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.lastStudyDate = Date()
        stats.currentStreak = 5
        stats.longestStreak = 10

        // When
        sut.updateStreak(&stats)

        // Then
        XCTAssertEqual(stats.currentStreak, 5)
        XCTAssertEqual(stats.longestStreak, 10)
    }

    func testUpdateStreak_StreakBroken_ResetsToOne() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        stats.lastStudyDate = threeDaysAgo
        stats.currentStreak = 5
        stats.longestStreak = 5

        // When
        sut.updateStreak(&stats)

        // Then
        XCTAssertEqual(stats.currentStreak, 1)
        XCTAssertEqual(stats.longestStreak, 5, "Longest streak should not decrease")
    }

    // MARK: - Check Achievements Tests

    func testCheckAchievements_UnlocksStreakAchievement() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.currentStreak = 7
        var unlockedAchievements: [String: Achievement] = [:]

        // When
        let newlyUnlocked = sut.checkAchievements(
            stats: stats, unlockedAchievements: &unlockedAchievements)

        // Then
        XCTAssertGreaterThan(newlyUnlocked.count, 0)
        XCTAssertTrue(newlyUnlocked.contains { $0.id == "streak_7" })
    }

    func testCheckAchievements_UnlocksStudyTimeAchievement() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.totalStudyTime = 36000  // 10 hours = 600 minutes
        var unlockedAchievements: [String: Achievement] = [:]

        // When
        let newlyUnlocked = sut.checkAchievements(
            stats: stats, unlockedAchievements: &unlockedAchievements)

        // Then
        XCTAssertTrue(newlyUnlocked.contains { $0.id == "time_10" })
    }

    func testCheckAchievements_UnlocksFlashcardAchievement() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.totalFlashcardsReviewed = 100
        var unlockedAchievements: [String: Achievement] = [:]

        // When
        let newlyUnlocked = sut.checkAchievements(
            stats: stats, unlockedAchievements: &unlockedAchievements)

        // Then
        XCTAssertTrue(newlyUnlocked.contains { $0.id == "flashcard_100" })
    }

    func testCheckAchievements_DoesNotUnlockAlreadyUnlocked() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.currentStreak = 7
        var unlockedAchievements: [String: Achievement] = [:]

        // First unlock
        _ = sut.checkAchievements(stats: stats, unlockedAchievements: &unlockedAchievements)
        let firstCount = unlockedAchievements.count

        // When - Check again
        let newlyUnlocked = sut.checkAchievements(
            stats: stats, unlockedAchievements: &unlockedAchievements)

        // Then
        XCTAssertEqual(newlyUnlocked.count, 0, "Should not unlock same achievement twice")
        XCTAssertEqual(unlockedAchievements.count, firstCount)
    }

    func testCheckAchievements_UnlocksMultipleAchievements() {
        // Given
        var stats = StudyStatistics(userId: "user-1")
        stats.currentStreak = 14  // Should unlock streak_3, streak_7, streak_14
        var unlockedAchievements: [String: Achievement] = [:]

        // When
        let newlyUnlocked = sut.checkAchievements(
            stats: stats, unlockedAchievements: &unlockedAchievements)

        // Then
        let streakAchievements = newlyUnlocked.filter { $0.category == .streak }
        XCTAssertGreaterThanOrEqual(streakAchievements.count, 3)
    }

    // MARK: - Update Goal Tests

    func testUpdateGoal_IncrementsProgress() {
        // Given
        var goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 50
        )

        // When
        sut.updateGoal(&goal, increment: 10)

        // Then
        XCTAssertEqual(goal.current, 60)
    }

    func testUpdateGoal_CapsAtTarget() {
        // Given
        var goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 95
        )

        // When
        sut.updateGoal(&goal, increment: 10)

        // Then
        XCTAssertEqual(goal.current, 100)
    }

    func testUpdateGoal_MarksAsCompleted() {
        // Given
        var goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 99
        )

        // When
        sut.updateGoal(&goal, increment: 1)

        // Then
        XCTAssertTrue(goal.completed)
        XCTAssertNotNil(goal.completedDate)
    }

    func testCheckGoalCompletion_ReturnsTrue_WhenReached() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 100
        )

        // When
        let isComplete = sut.checkGoalCompletion(goal)

        // Then
        XCTAssertTrue(isComplete)
    }

    func testCheckGoalCompletion_ReturnsFalse_WhenNotReached() {
        // Given
        let goal = Goal(
            userId: "user-1",
            title: "Test",
            description: "Test",
            type: .studyTime,
            target: 100,
            current: 50
        )

        // When
        let isComplete = sut.checkGoalCompletion(goal)

        // Then
        XCTAssertFalse(isComplete)
    }
}
