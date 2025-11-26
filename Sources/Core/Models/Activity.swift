import Foundation

/// Represents an activity in the user's study history
public struct Activity: Identifiable, Codable, Equatable {
    public let id: String
    public var userId: String
    public var type: ActivityType
    public var title: String
    public var description: String
    public var metadata: [String: String]
    public var timestamp: Date

    public init(
        id: String = UUID().uuidString,
        userId: String,
        type: ActivityType,
        title: String,
        description: String,
        metadata: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.description = description
        self.metadata = metadata
        self.timestamp = timestamp
    }

    /// Create activity for class creation
    public static func classCreated(
        userId: String,
        className: String,
        classId: String
    ) -> Activity {
        Activity(
            userId: userId,
            type: .classCreated,
            title: "Class Added",
            description: "Created \(className)",
            metadata: ["classId": classId, "className": className]
        )
    }

    /// Create activity for note creation
    public static func noteCreated(
        userId: String,
        noteTitle: String,
        noteId: String,
        classId: String
    ) -> Activity {
        Activity(
            userId: userId,
            type: .noteCreated,
            title: "Note Created",
            description: "Added note: \(noteTitle)",
            metadata: ["noteId": noteId, "classId": classId, "noteTitle": noteTitle]
        )
    }

    /// Create activity for flashcard review
    public static func flashcardReviewed(
        userId: String,
        count: Int,
        classId: String,
        className: String
    ) -> Activity {
        Activity(
            userId: userId,
            type: .flashcardReviewed,
            title: "Flashcards Reviewed",
            description: "Reviewed \(count) flashcard\(count == 1 ? "" : "s") in \(className)",
            metadata: ["count": "\(count)", "classId": classId, "className": className]
        )
    }

    /// Create activity for study session completion
    public static func studySessionCompleted(
        userId: String,
        duration: TimeInterval,
        sessionType: String
    ) -> Activity {
        let minutes = Int(duration / 60)
        return Activity(
            userId: userId,
            type: .studySessionCompleted,
            title: "Study Session Completed",
            description: "Studied for \(minutes) minutes",
            metadata: ["duration": "\(duration)", "sessionType": sessionType]
        )
    }

    /// Create activity for achievement
    public static func achievementUnlocked(
        userId: String,
        achievementTitle: String,
        achievementId: String
    ) -> Activity {
        Activity(
            userId: userId,
            type: .achievementUnlocked,
            title: "Achievement Unlocked! 🎉",
            description: achievementTitle,
            metadata: ["achievementId": achievementId, "achievementTitle": achievementTitle]
        )
    }
}

/// Type of activity
public enum ActivityType: String, Codable {
    case classCreated = "class_created"
    case classUpdated = "class_updated"
    case classDeleted = "class_deleted"
    case noteCreated = "note_created"
    case noteUpdated = "note_updated"
    case noteDeleted = "note_deleted"
    case flashcardCreated = "flashcard_created"
    case flashcardReviewed = "flashcard_reviewed"
    case studySessionCompleted = "study_session_completed"
    case achievementUnlocked = "achievement_unlocked"
    case goalCompleted = "goal_completed"
    case streakMilestone = "streak_milestone"

    public var icon: String {
        switch self {
        case .classCreated, .classUpdated:
            return "book.fill"
        case .classDeleted:
            return "trash.fill"
        case .noteCreated, .noteUpdated:
            return "doc.text.fill"
        case .noteDeleted:
            return "doc.text"
        case .flashcardCreated:
            return "rectangle.stack.badge.plus"
        case .flashcardReviewed:
            return "checkmark.circle.fill"
        case .studySessionCompleted:
            return "clock.fill"
        case .achievementUnlocked:
            return "star.fill"
        case .goalCompleted:
            return "flag.checkered"
        case .streakMilestone:
            return "flame.fill"
        }
    }

    public var color: String {
        switch self {
        case .classCreated, .classUpdated:
            return "purple"
        case .classDeleted, .noteDeleted:
            return "red"
        case .noteCreated, .noteUpdated:
            return "blue"
        case .flashcardCreated, .flashcardReviewed:
            return "green"
        case .studySessionCompleted:
            return "orange"
        case .achievementUnlocked:
            return "yellow"
        case .goalCompleted:
            return "pink"
        case .streakMilestone:
            return "red"
        }
    }
}

/// Protocol for Activity Repository
public protocol ActivityRepositoryProtocol {
    func getActivities(for userId: String, limit: Int) async throws -> [Activity]
    func getActivitiesByType(for userId: String, type: ActivityType) async throws -> [Activity]
    func getActivitiesForClass(classId: String) async throws -> [Activity]
    func createActivity(_ activity: Activity) async throws -> Activity
    func deleteActivity(id: String) async throws
    func deleteActivitiesForUser(userId: String) async throws
}

/// Mock implementation of Activity Repository
public final class MockActivityRepositoryImpl: ActivityRepositoryProtocol {
    private var activities: [String: Activity] = [:]

    public init() {}

    public func getActivities(for userId: String, limit: Int) async throws -> [Activity] {
        try await Task.sleep(nanoseconds: 100_000_000)

        return activities.values
            .filter { $0.userId == userId }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit)
            .map { $0 }
    }

    public func getActivitiesByType(for userId: String, type: ActivityType) async throws
        -> [Activity]
    {
        try await Task.sleep(nanoseconds: 100_000_000)

        return activities.values
            .filter { $0.userId == userId && $0.type == type }
            .sorted { $0.timestamp > $1.timestamp }
    }

    public func getActivitiesForClass(classId: String) async throws -> [Activity] {
        try await Task.sleep(nanoseconds: 100_000_000)

        return activities.values
            .filter { $0.metadata["classId"] == classId }
            .sorted { $0.timestamp > $1.timestamp }
    }

    public func createActivity(_ activity: Activity) async throws -> Activity {
        try await Task.sleep(nanoseconds: 100_000_000)

        activities[activity.id] = activity
        return activity
    }

    public func deleteActivity(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)

        guard activities[id] != nil else {
            throw AppError.notFound("Activity not found")
        }

        activities.removeValue(forKey: id)
    }

    public func deleteActivitiesForUser(userId: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)

        let userActivityIds = activities.values
            .filter { $0.userId == userId }
            .map { $0.id }

        for id in userActivityIds {
            activities.removeValue(forKey: id)
        }
    }
}
