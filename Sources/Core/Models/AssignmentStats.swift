import Foundation

/// Statistics about assignments for a class
public struct AssignmentStats: Equatable {
    public let classId: String
    public let total: Int
    public let completed: Int
    public let notSubmitted: Int
    public let expired: Int
    public let currentDue: Int  // Due within this week
    public let upcoming: Int    // Due in more than a week
    
    public init(
        classId: String,
        total: Int = 0,
        completed: Int = 0,
        notSubmitted: Int = 0,
        expired: Int = 0,
        currentDue: Int = 0,
        upcoming: Int = 0
    ) {
        self.classId = classId
        self.total = total
        self.completed = completed
        self.notSubmitted = notSubmitted
        self.expired = expired
        self.currentDue = currentDue
        self.upcoming = upcoming
    }
    
    /// Convenience: assignments that need attention (not submitted, expired, or due soon)
    public var needsAttention: Int {
        notSubmitted + expired + currentDue
    }
}
