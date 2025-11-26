import Foundation
import UserNotifications

/// Manages local notifications for study reminders and class notifications
public final class NotificationManager: NSObject {
    
    public static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    public enum NotificationCategory: String {
        case studyReminder = "STUDY_REMINDER"
        case classReminder = "CLASS_REMINDER"
        case flashcardReview = "FLASHCARD_REVIEW"
        case achievement = "ACHIEVEMENT"
    }
    
    public enum NotificationError: Error {
        case permissionDenied
        case schedulingFailed
        case invalidIdentifier
    }
    
    private override init() {
        super.init()
        center.delegate = self
    }
    
    // MARK: - Permission Management
    
    /// Request notification permissions from the user
    public func requestPermissions() async throws -> Bool {
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        case .denied, .ephemeral:
            throw NotificationError.permissionDenied
        @unknown default:
            throw NotificationError.permissionDenied
        }
    }
    
    /// Check current notification authorization status
    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Scheduling Notifications
    
    /// Schedule a study reminder
    public func scheduleStudyReminder(
        at date: Date,
        title: String = "Time to Study!",
        body: String,
        classId: String? = nil
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.studyReminder.rawValue
        
        if let classId = classId {
            content.userInfo = ["classId": classId]
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "study_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Schedule a class reminder
    public func scheduleClassReminder(
        classId: String,
        className: String,
        location: String?,
        startTime: Date,
        minutesBefore: Int = 15
    ) async throws {
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: startTime) else {
            throw NotificationError.schedulingFailed
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Class Starting Soon"
        content.body = "\(className) starts in \(minutesBefore) minutes"
        if let location = location {
            content.subtitle = "Location: \(location)"
        }
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.classReminder.rawValue
        content.userInfo = ["classId": classId]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "class_\(classId)_\(startTime.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Schedule a recurring daily study reminder
    public func scheduleDailyStudyReminder(
        hour: Int,
        minute: Int,
        title: String = "Daily Study Time",
        body: String = "Don't forget to review your flashcards!"
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.studyReminder.rawValue
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "daily_study_\(hour)_\(minute)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Schedule flashcard review reminder
    public func scheduleFlashcardReview(
        classId: String,
        className: String,
        dueCount: Int,
        at date: Date
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Flashcards Due for Review"
        content.body = "\(dueCount) flashcard\(dueCount == 1 ? "" : "s") in \(className) ready to review"
        content.sound = .default
        content.badge = NSNumber(value: dueCount)
        content.categoryIdentifier = NotificationCategory.flashcardReview.rawValue
        content.userInfo = ["classId": classId, "dueCount": dueCount]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "flashcard_\(classId)_\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Schedule achievement notification
    public func scheduleAchievement(
        title: String,
        description: String,
        achievementId: String
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🎉"
        content.body = "\(title): \(description)"
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.achievement.rawValue
        content.userInfo = ["achievementId": achievementId]
        
        // Show immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifier = "achievement_\(achievementId)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    // MARK: - Managing Notifications
    
    /// Cancel a specific notification
    public func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel all notifications for a specific category
    public func cancelNotifications(for category: NotificationCategory) async {
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests
            .filter { $0.content.categoryIdentifier == category.rawValue }
            .map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Cancel all notifications for a specific class
    public func cancelClassNotifications(classId: String) async {
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests
            .filter { ($0.content.userInfo["classId"] as? String) == classId }
            .map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Cancel all pending notifications
    public func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Get all pending notifications
    public func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    /// Get count of pending notifications
    public func getPendingNotificationCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    // MARK: - Badge Management
    
    /// Update app badge count
    public func updateBadgeCount(_ count: Int) {
        center.setBadgeCount(count)
    }
    
    /// Clear app badge
    public func clearBadge() {
        center.setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// Handle notification when app is in foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        // Post notification for app to handle
        NotificationCenter.default.post(
            name: .notificationTapped,
            object: nil,
            userInfo: [
                "category": categoryIdentifier,
                "data": userInfo
            ]
        )
        
        completionHandler()
    }
}

// MARK: - Notification Names

public extension Notification.Name {
    static let notificationTapped = Notification.Name("notificationTapped")
}
