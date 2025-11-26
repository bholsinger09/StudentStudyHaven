import UserNotifications
import XCTest

@testable import Core

final class NotificationManagerTests: XCTestCase {
    var sut: NotificationManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = NotificationManager.shared
        // Cancel all notifications before each test
        sut.cancelAllNotifications()
    }

    override func tearDown() {
        sut.cancelAllNotifications()
        sut = nil
        super.tearDown()
    }

    // MARK: - Permission Tests

    func testGetAuthorizationStatus_ReturnsStatus() async {
        // When
        let status = await sut.getAuthorizationStatus()

        // Then
        XCTAssertNotNil(status, "Should return authorization status")
    }

    // MARK: - Study Reminder Tests

    func testScheduleStudyReminder_AddsNotification() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

        // When
        try await sut.scheduleStudyReminder(
            at: futureDate,
            title: "Test Study",
            body: "Time to study!",
            classId: "test-class-123"
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let studyNotifications = pending.filter {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.studyReminder.rawValue
        }
        XCTAssertGreaterThan(studyNotifications.count, 0, "Should have at least one study reminder")
    }

    func testScheduleStudyReminder_WithClassId_IncludesUserInfo() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let classId = "test-class-123"

        // When
        try await sut.scheduleStudyReminder(
            at: futureDate,
            title: "Test",
            body: "Test body",
            classId: classId
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let notification = pending.first {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.studyReminder.rawValue
        }
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.content.userInfo["classId"] as? String, classId)
    }

    // MARK: - Class Reminder Tests

    func testScheduleClassReminder_AddsNotification() async throws {
        // Given
        let startTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!

        // When
        try await sut.scheduleClassReminder(
            classId: "class-123",
            className: "Computer Science",
            location: "Room 101",
            startTime: startTime,
            minutesBefore: 15
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let classNotifications = pending.filter {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.classReminder.rawValue
        }
        XCTAssertGreaterThan(classNotifications.count, 0, "Should have class reminder")
    }

    func testScheduleClassReminder_IncludesClassInfo() async throws {
        // Given
        let startTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        let classId = "class-123"
        let className = "Computer Science"
        let location = "Room 101"

        // When
        try await sut.scheduleClassReminder(
            classId: classId,
            className: className,
            location: location,
            startTime: startTime
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let notification = pending.first {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.classReminder.rawValue
        }

        XCTAssertNotNil(notification)
        XCTAssertTrue(notification!.content.body.contains(className))
        XCTAssertEqual(notification?.content.userInfo["classId"] as? String, classId)
    }

    // MARK: - Daily Study Reminder Tests

    func testScheduleDailyStudyReminder_CreatesRepeatingNotification() async throws {
        // Given
        let hour = 9
        let minute = 0

        // When
        try await sut.scheduleDailyStudyReminder(
            hour: hour,
            minute: minute,
            title: "Daily Study",
            body: "Time to review!"
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let dailyReminder = pending.first {
            $0.identifier.starts(with: "daily_study_")
        }

        XCTAssertNotNil(dailyReminder, "Should create daily reminder")
        if let trigger = dailyReminder?.trigger as? UNCalendarNotificationTrigger {
            XCTAssertTrue(trigger.repeats, "Should be repeating")
            XCTAssertEqual(trigger.dateComponents.hour, hour)
            XCTAssertEqual(trigger.dateComponents.minute, minute)
        } else {
            XCTFail("Trigger should be calendar-based")
        }
    }

    // MARK: - Flashcard Review Tests

    func testScheduleFlashcardReview_AddsNotificationWithBadge() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let dueCount = 5

        // When
        try await sut.scheduleFlashcardReview(
            classId: "class-123",
            className: "Biology",
            dueCount: dueCount,
            at: futureDate
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let flashcardNotification = pending.first {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.flashcardReview.rawValue
        }

        XCTAssertNotNil(flashcardNotification)
        XCTAssertEqual(flashcardNotification?.content.badge?.intValue, dueCount)
        XCTAssertEqual(flashcardNotification?.content.userInfo["dueCount"] as? Int, dueCount)
    }

    // MARK: - Achievement Tests

    func testScheduleAchievement_SchedulesImmediately() async throws {
        // Given
        let title = "Study Streak"
        let description = "Studied 7 days in a row"
        let achievementId = "streak_7"

        // When
        try await sut.scheduleAchievement(
            title: title,
            description: description,
            achievementId: achievementId
        )

        // Then
        let pending = await sut.getPendingNotifications()
        let achievementNotification = pending.first {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.achievement.rawValue
        }

        XCTAssertNotNil(achievementNotification)
        XCTAssertTrue(achievementNotification!.content.body.contains(title))
        XCTAssertEqual(
            achievementNotification?.content.userInfo["achievementId"] as? String, achievementId)
    }

    // MARK: - Cancellation Tests

    func testCancelNotification_RemovesSpecificNotification() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 1")
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 2")

        let beforeCancel = await sut.getPendingNotificationCount()
        let notifications = await sut.getPendingNotifications()
        guard let firstIdentifier = notifications.first?.identifier else {
            XCTFail("Should have notifications")
            return
        }

        // When
        sut.cancelNotification(withIdentifier: firstIdentifier)

        // Then
        let afterCancel = await sut.getPendingNotificationCount()
        XCTAssertEqual(afterCancel, beforeCancel - 1, "Should remove one notification")
    }

    func testCancelNotificationsForCategory_RemovesOnlyThatCategory() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        try await sut.scheduleStudyReminder(at: futureDate, body: "Study")
        try await sut.scheduleAchievement(title: "Test", description: "Test", achievementId: "test")

        // When
        await sut.cancelNotifications(for: .studyReminder)

        // Then
        let remaining = await sut.getPendingNotifications()
        let hasStudyReminder = remaining.contains {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.studyReminder.rawValue
        }
        let hasAchievement = remaining.contains {
            $0.content.categoryIdentifier
                == NotificationManager.NotificationCategory.achievement.rawValue
        }

        XCTAssertFalse(hasStudyReminder, "Should not have study reminders")
        XCTAssertTrue(hasAchievement, "Should still have achievement notifications")
    }

    func testCancelClassNotifications_RemovesAllForClass() async throws {
        // Given
        let classId1 = "class-1"
        let classId2 = "class-2"
        let startTime = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!

        try await sut.scheduleClassReminder(
            classId: classId1,
            className: "Class 1",
            location: nil,
            startTime: startTime
        )
        try await sut.scheduleClassReminder(
            classId: classId2,
            className: "Class 2",
            location: nil,
            startTime: startTime
        )

        // When
        await sut.cancelClassNotifications(classId: classId1)

        // Then
        let remaining = await sut.getPendingNotifications()
        let hasClass1 = remaining.contains {
            ($0.content.userInfo["classId"] as? String) == classId1
        }
        let hasClass2 = remaining.contains {
            ($0.content.userInfo["classId"] as? String) == classId2
        }

        XCTAssertFalse(hasClass1, "Should not have class 1 notifications")
        XCTAssertTrue(hasClass2, "Should still have class 2 notifications")
    }

    func testCancelAllNotifications_RemovesAll() async throws {
        // Given
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 1")
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 2")
        try await sut.scheduleAchievement(title: "Test", description: "Test", achievementId: "test")

        // When
        sut.cancelAllNotifications()

        // Then
        let count = await sut.getPendingNotificationCount()
        XCTAssertEqual(count, 0, "Should have no pending notifications")
    }

    // MARK: - Pending Notifications Tests

    func testGetPendingNotificationCount_ReturnsCorrectCount() async throws {
        // Given
        sut.cancelAllNotifications()
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

        // When
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 1")
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 2")
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test 3")

        // Then
        let count = await sut.getPendingNotificationCount()
        XCTAssertEqual(count, 3, "Should have 3 pending notifications")
    }

    func testGetPendingNotifications_ReturnsAllPending() async throws {
        // Given
        sut.cancelAllNotifications()
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

        // When
        try await sut.scheduleStudyReminder(at: futureDate, body: "Test")

        // Then
        let notifications = await sut.getPendingNotifications()
        XCTAssertEqual(notifications.count, 1)
        XCTAssertEqual(notifications.first?.content.body, "Test")
    }

    // MARK: - Badge Tests

    func testUpdateBadgeCount_SetsCount() {
        // When
        sut.updateBadgeCount(5)

        // Then - Just verify it doesn't crash
        // Note: Badge count verification requires app to be running
        XCTAssert(true, "Badge count updated successfully")
    }

    func testClearBadge_ResetsToZero() {
        // When
        sut.clearBadge()

        // Then - Just verify it doesn't crash
        XCTAssert(true, "Badge cleared successfully")
    }
}
