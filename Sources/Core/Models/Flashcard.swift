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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
