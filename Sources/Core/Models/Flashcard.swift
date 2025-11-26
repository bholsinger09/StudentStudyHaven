import Foundation

/// Domain model representing a Flashcard
public struct Flashcard: Identifiable, Codable, Equatable {
    public let id: String
    public var classId: String
    public var userId: String
    public var front: String
    public var back: String
    public var noteIds: [String]
    public var lastReviewedAt: Date?
    public var reviewData: ReviewData?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        classId: String,
        userId: String,
        front: String,
        back: String,
        noteIds: [String] = [],
        lastReviewedAt: Date? = nil,
        reviewData: ReviewData? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.classId = classId
        self.userId = userId
        self.front = front
        self.back = back
        self.noteIds = noteIds
        self.lastReviewedAt = lastReviewedAt
        self.reviewData = reviewData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Review data for spaced repetition
public struct ReviewData: Codable, Equatable {
    public var repetitions: Int
    public var easeFactor: Double
    public var interval: Int
    public var nextReviewDate: Date
    public var lastReviewDate: Date?

    public init(
        repetitions: Int = 0,
        easeFactor: Double = 2.5,
        interval: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewDate: Date? = nil
    ) {
        self.repetitions = repetitions
        self.easeFactor = easeFactor
        self.interval = interval
        self.nextReviewDate = nextReviewDate
        self.lastReviewDate = lastReviewDate
    }
}
