import Foundation

/// Domain model representing a Class/Course
public struct Class: Identifiable, Codable, Equatable {
    public let id: String
    public var userId: String
    public var name: String
    public var courseCode: String
    public var schedule: [TimeSlot]
    public var professor: String?
    public var location: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        courseCode: String,
        schedule: [TimeSlot] = [],
        professor: String? = nil,
        location: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.courseCode = courseCode
        self.schedule = schedule
        self.professor = professor
        self.location = location
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Represents a time slot for a class
    public struct TimeSlot: Codable, Equatable, Identifiable {
        public let id: String
        public var dayOfWeek: DayOfWeek
        public var startTime: Date
        public var endTime: Date

        public init(
            id: String = UUID().uuidString,
            dayOfWeek: DayOfWeek,
            startTime: Date,
            endTime: Date
        ) {
            self.id = id
            self.dayOfWeek = dayOfWeek
            self.startTime = startTime
            self.endTime = endTime
        }
    }
}

/// Days of the week
public enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}
