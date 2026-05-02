import Foundation

/// Domain model representing a scheduled Group Study Session
public struct GroupStudySession: Identifiable, Codable, Equatable {
    public let id: String
    public var studyGroupId: String
    public var title: String
    public var description: String?
    public var scheduledAt: Date
    public var durationMinutes: Int
    public var location: String?
    public var isVirtual: Bool
    public var meetingLink: String?
    public var createdBy: String // userId
    public var attendeeIds: [String]
    public var maxAttendees: Int?
    public var status: SessionStatus
    public var createdAt: Date
    public var updatedAt: Date
    
    public enum SessionStatus: String, Codable, Equatable {
        case scheduled
        case inProgress
        case completed
        case cancelled
    }
    
    public init(
        id: String = UUID().uuidString,
        studyGroupId: String,
        title: String,
        description: String? = nil,
        scheduledAt: Date,
        durationMinutes: Int = 60,
        location: String? = nil,
        isVirtual: Bool = false,
        meetingLink: String? = nil,
        createdBy: String,
        attendeeIds: [String] = [],
        maxAttendees: Int? = nil,
        status: SessionStatus = .scheduled,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.studyGroupId = studyGroupId
        self.title = title
        self.description = description
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        self.location = location
        self.isVirtual = isVirtual
        self.meetingLink = meetingLink
        self.createdBy = createdBy
        self.attendeeIds = attendeeIds
        self.maxAttendees = maxAttendees
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Check if session is full
    public var isFull: Bool {
        guard let max = maxAttendees else { return false }
        return attendeeIds.count >= max
    }
    
    /// Check if user is attending
    public func isAttending(_ userId: String) -> Bool {
        return attendeeIds.contains(userId)
    }
    
    /// Check if session has started
    public var hasStarted: Bool {
        return scheduledAt <= Date()
    }
    
    /// Check if session is upcoming (within next 24 hours)
    public var isUpcoming: Bool {
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        return scheduledAt > now && scheduledAt <= tomorrow
    }
}
