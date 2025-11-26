import Foundation

/// Statistics and analytics for study performance
public struct StudyStatistics: Codable {
    public var userId: String
    public var totalStudyTime: TimeInterval // in seconds
    public var totalSessions: Int
    public var totalFlashcardsReviewed: Int
    public var totalNotesCreated: Int
    public var totalClassesCreated: Int
    public var currentStreak: Int // consecutive days
    public var longestStreak: Int
    public var lastStudyDate: Date?
    public var weeklyStats: [WeeklyStats]
    public var flashcardAccuracy: Double // 0.0 to 1.0
    
    public init(
        userId: String,
        totalStudyTime: TimeInterval = 0,
        totalSessions: Int = 0,
        totalFlashcardsReviewed: Int = 0,
        totalNotesCreated: Int = 0,
        totalClassesCreated: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastStudyDate: Date? = nil,
        weeklyStats: [WeeklyStats] = [],
        flashcardAccuracy: Double = 0.0
    ) {
        self.userId = userId
        self.totalStudyTime = totalStudyTime
        self.totalSessions = totalSessions
        self.totalFlashcardsReviewed = totalFlashcardsReviewed
        self.totalNotesCreated = totalNotesCreated
        self.totalClassesCreated = totalClassesCreated
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastStudyDate = lastStudyDate
        self.weeklyStats = weeklyStats
        self.flashcardAccuracy = flashcardAccuracy
    }
    
    /// Format total study time as hours and minutes
    public var formattedStudyTime: String {
        let hours = Int(totalStudyTime) / 3600
        let minutes = (Int(totalStudyTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Average study time per session
    public var averageSessionDuration: TimeInterval {
        guard totalSessions > 0 else { return 0 }
        return totalStudyTime / Double(totalSessions)
    }
    
    /// Formatted accuracy percentage
    public var formattedAccuracy: String {
        return String(format: "%.1f%%", flashcardAccuracy * 100)
    }
}

/// Weekly statistics for trend analysis
public struct WeeklyStats: Codable, Identifiable {
    public let id: String
    public var weekStart: Date
    public var weekEnd: Date
    public var totalMinutes: Int
    public var sessionsCompleted: Int
    public var flashcardsReviewed: Int
    
    public init(
        id: String = UUID().uuidString,
        weekStart: Date,
        weekEnd: Date,
        totalMinutes: Int = 0,
        sessionsCompleted: Int = 0,
        flashcardsReviewed: Int = 0
    ) {
        self.id = id
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.totalMinutes = totalMinutes
        self.sessionsCompleted = sessionsCompleted
        self.flashcardsReviewed = flashcardsReviewed
    }
}

/// Goal tracking
public struct Goal: Identifiable, Codable {
    public let id: String
    public var userId: String
    public var title: String
    public var description: String
    public var type: GoalType
    public var target: Int
    public var current: Int
    public var deadline: Date?
    public var completed: Bool
    public var completedDate: Date?
    public var createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        description: String,
        type: GoalType,
        target: Int,
        current: Int = 0,
        deadline: Date? = nil,
        completed: Bool = false,
        completedDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.type = type
        self.target = target
        self.current = current
        self.deadline = deadline
        self.completed = completed
        self.completedDate = completedDate
        self.createdAt = createdAt
    }
    
    /// Progress as a percentage (0.0 to 1.0)
    public var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    /// Formatted progress percentage
    public var formattedProgress: String {
        return String(format: "%.0f%%", progress * 100)
    }
    
    /// Check if goal is overdue
    public var isOverdue: Bool {
        guard let deadline = deadline, !completed else { return false }
        return Date() > deadline
    }
}

public enum GoalType: String, Codable {
    case studyTime = "study_time" // minutes
    case flashcards = "flashcards" // count
    case notes = "notes" // count
    case streak = "streak" // days
    case sessions = "sessions" // count
    case classes = "classes" // count
    
    public var displayName: String {
        switch self {
        case .studyTime: return "Study Time"
        case .flashcards: return "Flashcards"
        case .notes: return "Notes"
        case .streak: return "Study Streak"
        case .sessions: return "Study Sessions"
        case .classes: return "Classes"
        }
    }
    
    public var unit: String {
        switch self {
        case .studyTime: return "minutes"
        case .flashcards: return "flashcards"
        case .notes: return "notes"
        case .streak: return "days"
        case .sessions: return "sessions"
        case .classes: return "classes"
        }
    }
    
    public var icon: String {
        switch self {
        case .studyTime: return "clock.fill"
        case .flashcards: return "rectangle.stack.fill"
        case .notes: return "doc.text.fill"
        case .streak: return "flame.fill"
        case .sessions: return "timer"
        case .classes: return "book.fill"
        }
    }
}

/// Achievement system
public struct Achievement: Identifiable, Codable {
    public let id: String
    public var title: String
    public var description: String
    public var category: AchievementCategory
    public var requirement: Int
    public var icon: String
    public var unlockedDate: Date?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: AchievementCategory,
        requirement: Int,
        icon: String,
        unlockedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.requirement = requirement
        self.icon = icon
        self.unlockedDate = unlockedDate
    }
    
    public var isUnlocked: Bool {
        unlockedDate != nil
    }
}

public enum AchievementCategory: String, Codable {
    case streak = "streak"
    case studyTime = "study_time"
    case flashcards = "flashcards"
    case notes = "notes"
    case classes = "classes"
    case perfectWeek = "perfect_week"
    
    public var displayName: String {
        switch self {
        case .streak: return "Streak Master"
        case .studyTime: return "Time Warrior"
        case .flashcards: return "Flashcard Expert"
        case .notes: return "Note Taker"
        case .classes: return "Class Champion"
        case .perfectWeek: return "Perfect Week"
        }
    }
}

/// Predefined achievements
public extension Achievement {
    static let allAchievements: [Achievement] = [
        // Streak achievements
        Achievement(id: "streak_3", title: "Getting Started", description: "Study 3 days in a row", category: .streak, requirement: 3, icon: "flame.fill"),
        Achievement(id: "streak_7", title: "Week Warrior", description: "Study 7 days in a row", category: .streak, requirement: 7, icon: "flame.fill"),
        Achievement(id: "streak_14", title: "Two Week Champion", description: "Study 14 days in a row", category: .streak, requirement: 14, icon: "flame.fill"),
        Achievement(id: "streak_30", title: "Month Master", description: "Study 30 days in a row", category: .streak, requirement: 30, icon: "flame.fill"),
        
        // Study time achievements
        Achievement(id: "time_10", title: "First Steps", description: "Study for 10 hours total", category: .studyTime, requirement: 600, icon: "clock.fill"),
        Achievement(id: "time_50", title: "Dedicated Student", description: "Study for 50 hours total", category: .studyTime, requirement: 3000, icon: "clock.fill"),
        Achievement(id: "time_100", title: "Century Club", description: "Study for 100 hours total", category: .studyTime, requirement: 6000, icon: "clock.fill"),
        
        // Flashcard achievements
        Achievement(id: "flashcard_100", title: "Card Novice", description: "Review 100 flashcards", category: .flashcards, requirement: 100, icon: "rectangle.stack.fill"),
        Achievement(id: "flashcard_500", title: "Card Expert", description: "Review 500 flashcards", category: .flashcards, requirement: 500, icon: "rectangle.stack.fill"),
        Achievement(id: "flashcard_1000", title: "Card Master", description: "Review 1000 flashcards", category: .flashcards, requirement: 1000, icon: "rectangle.stack.fill"),
        
        // Note achievements
        Achievement(id: "note_10", title: "Note Starter", description: "Create 10 notes", category: .notes, requirement: 10, icon: "doc.text.fill"),
        Achievement(id: "note_50", title: "Prolific Writer", description: "Create 50 notes", category: .notes, requirement: 50, icon: "doc.text.fill"),
        
        // Class achievements
        Achievement(id: "class_5", title: "Multi-Tasker", description: "Add 5 classes", category: .classes, requirement: 5, icon: "book.fill"),
        Achievement(id: "class_10", title: "Full Schedule", description: "Add 10 classes", category: .classes, requirement: 10, icon: "book.fill")
    ]
}

/// Manager for tracking statistics and achievements
public final class ProgressTracker {
    
    /// Update statistics after a study session
    public func updateStatistics(
        _ stats: inout StudyStatistics,
        sessionDuration: TimeInterval,
        flashcardsReviewed: Int = 0,
        correctFlashcards: Int = 0
    ) {
        stats.totalStudyTime += sessionDuration
        stats.totalSessions += 1
        stats.totalFlashcardsReviewed += flashcardsReviewed
        
        // Update accuracy
        if flashcardsReviewed > 0 {
            let _ = Double(correctFlashcards) / Double(flashcardsReviewed)
            let totalCorrect = stats.flashcardAccuracy * Double(stats.totalFlashcardsReviewed - flashcardsReviewed) + Double(correctFlashcards)
            stats.flashcardAccuracy = totalCorrect / Double(stats.totalFlashcardsReviewed)
        }
        
        // Update streak
        updateStreak(&stats)
        
        stats.lastStudyDate = Date()
    }
    
    /// Update streak based on last study date
    public func updateStreak(_ stats: inout StudyStatistics) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = stats.lastStudyDate else {
            // First study session
            stats.currentStreak = 1
            stats.longestStreak = max(stats.longestStreak, 1)
            return
        }
        
        let lastStudyDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day, no change
            return
        } else if daysDifference == 1 {
            // Consecutive day
            stats.currentStreak += 1
            stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
        } else {
            // Streak broken
            stats.currentStreak = 1
        }
    }
    
    /// Check and unlock achievements based on statistics
    public func checkAchievements(
        stats: StudyStatistics,
        unlockedAchievements: inout [String: Achievement]
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        
        for achievement in Achievement.allAchievements {
            // Skip if already unlocked
            if unlockedAchievements[achievement.id] != nil {
                continue
            }
            
            let shouldUnlock: Bool
            
            switch achievement.category {
            case .streak:
                shouldUnlock = stats.currentStreak >= achievement.requirement
            case .studyTime:
                let totalMinutes = Int(stats.totalStudyTime / 60)
                shouldUnlock = totalMinutes >= achievement.requirement
            case .flashcards:
                shouldUnlock = stats.totalFlashcardsReviewed >= achievement.requirement
            case .notes:
                shouldUnlock = stats.totalNotesCreated >= achievement.requirement
            case .classes:
                shouldUnlock = stats.totalClassesCreated >= achievement.requirement
            case .perfectWeek:
                // Check if studied every day for a week
                shouldUnlock = stats.currentStreak >= 7
            }
            
            if shouldUnlock {
                var unlockedAchievement = achievement
                unlockedAchievement.unlockedDate = Date()
                unlockedAchievements[achievement.id] = unlockedAchievement
                newlyUnlocked.append(unlockedAchievement)
            }
        }
        
        return newlyUnlocked
    }
    
    /// Update goal progress
    public func updateGoal(_ goal: inout Goal, increment: Int = 1) {
        goal.current = min(goal.current + increment, goal.target)
        
        if goal.current >= goal.target && !goal.completed {
            goal.completed = true
            goal.completedDate = Date()
        }
    }
    
    /// Check if goal should be completed
    public func checkGoalCompletion(_ goal: Goal) -> Bool {
        return goal.current >= goal.target
    }
}
