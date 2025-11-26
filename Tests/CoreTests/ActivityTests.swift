import XCTest

@testable import Core

final class ActivityTests: XCTestCase {
    let testUserId = "user-123"

    // MARK: - Factory Method Tests

    func testClassCreated_CreatesCorrectActivity() {
        // Given
        let className = "Computer Science"
        let classId = "class-123"

        // When
        let activity = Activity.classCreated(
            userId: testUserId,
            className: className,
            classId: classId
        )

        // Then
        XCTAssertEqual(activity.type, .classCreated)
        XCTAssertEqual(activity.title, "Class Added")
        XCTAssertTrue(activity.description.contains(className))
        XCTAssertEqual(activity.metadata["classId"], classId)
        XCTAssertEqual(activity.metadata["className"], className)
    }

    func testNoteCreated_CreatesCorrectActivity() {
        // Given
        let noteTitle = "Chapter 1 Notes"
        let noteId = "note-123"
        let classId = "class-123"

        // When
        let activity = Activity.noteCreated(
            userId: testUserId,
            noteTitle: noteTitle,
            noteId: noteId,
            classId: classId
        )

        // Then
        XCTAssertEqual(activity.type, .noteCreated)
        XCTAssertEqual(activity.title, "Note Created")
        XCTAssertTrue(activity.description.contains(noteTitle))
        XCTAssertEqual(activity.metadata["noteId"], noteId)
        XCTAssertEqual(activity.metadata["classId"], classId)
    }

    func testFlashcardReviewed_CreatesCorrectActivity() {
        // Given
        let count = 10
        let classId = "class-123"
        let className = "Biology"

        // When
        let activity = Activity.flashcardReviewed(
            userId: testUserId,
            count: count,
            classId: classId,
            className: className
        )

        // Then
        XCTAssertEqual(activity.type, .flashcardReviewed)
        XCTAssertEqual(activity.title, "Flashcards Reviewed")
        XCTAssertTrue(activity.description.contains("\(count)"))
        XCTAssertTrue(activity.description.contains(className))
        XCTAssertEqual(activity.metadata["count"], "\(count)")
    }

    func testFlashcardReviewed_SingularForm_WhenCountIsOne() {
        // When
        let activity = Activity.flashcardReviewed(
            userId: testUserId,
            count: 1,
            classId: "class-123",
            className: "Math"
        )

        // Then
        XCTAssertTrue(activity.description.contains("1 flashcard"))
        XCTAssertFalse(activity.description.contains("flashcards"))
    }

    func testStudySessionCompleted_CreatesCorrectActivity() {
        // Given
        let duration: TimeInterval = 1500  // 25 minutes
        let sessionType = "Focus"

        // When
        let activity = Activity.studySessionCompleted(
            userId: testUserId,
            duration: duration,
            sessionType: sessionType
        )

        // Then
        XCTAssertEqual(activity.type, .studySessionCompleted)
        XCTAssertEqual(activity.title, "Study Session Completed")
        XCTAssertTrue(activity.description.contains("25 minutes"))
        XCTAssertEqual(activity.metadata["sessionType"], sessionType)
    }

    func testAchievementUnlocked_CreatesCorrectActivity() {
        // Given
        let achievementTitle = "7-Day Streak"
        let achievementId = "streak_7"

        // When
        let activity = Activity.achievementUnlocked(
            userId: testUserId,
            achievementTitle: achievementTitle,
            achievementId: achievementId
        )

        // Then
        XCTAssertEqual(activity.type, .achievementUnlocked)
        XCTAssertEqual(activity.title, "Achievement Unlocked! 🎉")
        XCTAssertEqual(activity.description, achievementTitle)
        XCTAssertEqual(activity.metadata["achievementId"], achievementId)
    }

    // MARK: - ActivityType Tests

    func testActivityType_HasCorrectIcons() {
        XCTAssertEqual(ActivityType.classCreated.icon, "book.fill")
        XCTAssertEqual(ActivityType.noteCreated.icon, "doc.text.fill")
        XCTAssertEqual(ActivityType.flashcardReviewed.icon, "checkmark.circle.fill")
        XCTAssertEqual(ActivityType.studySessionCompleted.icon, "clock.fill")
        XCTAssertEqual(ActivityType.achievementUnlocked.icon, "star.fill")
    }

    func testActivityType_HasCorrectColors() {
        XCTAssertEqual(ActivityType.classCreated.color, "purple")
        XCTAssertEqual(ActivityType.noteCreated.color, "blue")
        XCTAssertEqual(ActivityType.flashcardReviewed.color, "green")
        XCTAssertEqual(ActivityType.studySessionCompleted.color, "orange")
        XCTAssertEqual(ActivityType.achievementUnlocked.color, "yellow")
    }
}

final class MockActivityRepositoryTests: XCTestCase {
    var sut: MockActivityRepositoryImpl!
    let testUserId = "user-123"
    let otherUserId = "user-456"

    override func setUp() {
        super.setUp()
        sut = MockActivityRepositoryImpl()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Create Activity Tests

    func testCreateActivity_StoresActivity() async throws {
        // Given
        let activity = Activity.classCreated(
            userId: testUserId,
            className: "Test Class",
            classId: "class-123"
        )

        // When
        let created = try await sut.createActivity(activity)

        // Then
        XCTAssertEqual(created.id, activity.id)
        XCTAssertEqual(created.userId, testUserId)
    }

    // MARK: - Get Activities Tests

    func testGetActivities_ReturnsUserActivities() async throws {
        // Given
        let activity1 = Activity.classCreated(
            userId: testUserId, className: "Class 1", classId: "1")
        let activity2 = Activity.noteCreated(
            userId: testUserId, noteTitle: "Note 1", noteId: "1", classId: "1")
        let otherActivity = Activity.classCreated(
            userId: otherUserId, className: "Other", classId: "2")

        _ = try await sut.createActivity(activity1)
        _ = try await sut.createActivity(activity2)
        _ = try await sut.createActivity(otherActivity)

        // When
        let activities = try await sut.getActivities(for: testUserId, limit: 10)

        // Then
        XCTAssertEqual(activities.count, 2)
        XCTAssertTrue(activities.allSatisfy { $0.userId == testUserId })
    }

    func testGetActivities_RespectsLimit() async throws {
        // Given - Create 5 activities
        for i in 1...5 {
            let activity = Activity.classCreated(
                userId: testUserId, className: "Class \(i)", classId: "\(i)")
            _ = try await sut.createActivity(activity)
        }

        // When
        let activities = try await sut.getActivities(for: testUserId, limit: 3)

        // Then
        XCTAssertEqual(activities.count, 3)
    }

    func testGetActivities_SortsByTimestampDescending() async throws {
        // Given
        let oldActivity = Activity(
            userId: testUserId,
            type: .classCreated,
            title: "Old",
            description: "Old activity",
            timestamp: Date().addingTimeInterval(-3600)
        )
        let newActivity = Activity(
            userId: testUserId,
            type: .noteCreated,
            title: "New",
            description: "New activity",
            timestamp: Date()
        )

        _ = try await sut.createActivity(oldActivity)
        _ = try await sut.createActivity(newActivity)

        // When
        let activities = try await sut.getActivities(for: testUserId, limit: 10)

        // Then
        XCTAssertEqual(activities.first?.title, "New")
        XCTAssertEqual(activities.last?.title, "Old")
    }

    // MARK: - Get Activities By Type Tests

    func testGetActivitiesByType_FiltersCorrectly() async throws {
        // Given
        let classActivity = Activity.classCreated(
            userId: testUserId, className: "Class", classId: "1")
        let noteActivity = Activity.noteCreated(
            userId: testUserId, noteTitle: "Note", noteId: "1", classId: "1")
        let flashcardActivity = Activity.flashcardReviewed(
            userId: testUserId, count: 5, classId: "1", className: "Class")

        _ = try await sut.createActivity(classActivity)
        _ = try await sut.createActivity(noteActivity)
        _ = try await sut.createActivity(flashcardActivity)

        // When
        let activities = try await sut.getActivitiesByType(for: testUserId, type: .noteCreated)

        // Then
        XCTAssertEqual(activities.count, 1)
        XCTAssertEqual(activities.first?.type, .noteCreated)
    }

    func testGetActivitiesByType_ReturnsEmptyForNoMatches() async throws {
        // Given
        let activity = Activity.classCreated(userId: testUserId, className: "Class", classId: "1")
        _ = try await sut.createActivity(activity)

        // When
        let activities = try await sut.getActivitiesByType(
            for: testUserId, type: .achievementUnlocked)

        // Then
        XCTAssertEqual(activities.count, 0)
    }

    // MARK: - Get Activities For Class Tests

    func testGetActivitiesForClass_ReturnsClassActivities() async throws {
        // Given
        let classId = "class-123"
        let classActivity = Activity.classCreated(
            userId: testUserId, className: "Class", classId: classId)
        let noteActivity = Activity.noteCreated(
            userId: testUserId, noteTitle: "Note", noteId: "1", classId: classId)
        let otherClassActivity = Activity.classCreated(
            userId: testUserId, className: "Other", classId: "other")

        _ = try await sut.createActivity(classActivity)
        _ = try await sut.createActivity(noteActivity)
        _ = try await sut.createActivity(otherClassActivity)

        // When
        let activities = try await sut.getActivitiesForClass(classId: classId)

        // Then
        XCTAssertEqual(activities.count, 2)
        XCTAssertTrue(activities.allSatisfy { $0.metadata["classId"] == classId })
    }

    // MARK: - Delete Activity Tests

    func testDeleteActivity_RemovesActivity() async throws {
        // Given
        let activity = Activity.classCreated(userId: testUserId, className: "Class", classId: "1")
        let created = try await sut.createActivity(activity)

        // When
        try await sut.deleteActivity(id: created.id)

        // Then
        let activities = try await sut.getActivities(for: testUserId, limit: 10)
        XCTAssertEqual(activities.count, 0)
    }

    func testDeleteActivity_NonexistentActivity_ThrowsError() async {
        // When/Then
        do {
            try await sut.deleteActivity(id: "nonexistent")
            XCTFail("Should throw error")
        } catch let error as AppError {
            if case .notFound = error {
                XCTAssert(true)
            } else {
                XCTFail("Should throw notFound error")
            }
        } catch {
            XCTFail("Should throw AppError")
        }
    }

    // MARK: - Delete Activities For User Tests

    func testDeleteActivitiesForUser_RemovesAllUserActivities() async throws {
        // Given
        _ = try await sut.createActivity(
            Activity.classCreated(userId: testUserId, className: "Class 1", classId: "1"))
        _ = try await sut.createActivity(
            Activity.noteCreated(userId: testUserId, noteTitle: "Note 1", noteId: "1", classId: "1")
        )
        _ = try await sut.createActivity(
            Activity.classCreated(userId: otherUserId, className: "Other", classId: "2"))

        // When
        try await sut.deleteActivitiesForUser(userId: testUserId)

        // Then
        let testUserActivities = try await sut.getActivities(for: testUserId, limit: 10)
        let otherUserActivities = try await sut.getActivities(for: otherUserId, limit: 10)

        XCTAssertEqual(testUserActivities.count, 0)
        XCTAssertEqual(otherUserActivities.count, 1)
    }

    func testDeleteActivitiesForUser_NoActivities_DoesNotThrow() async throws {
        // When/Then - Should not throw
        try await sut.deleteActivitiesForUser(userId: "nonexistent-user")
        XCTAssert(true, "Should handle gracefully")
    }
}
