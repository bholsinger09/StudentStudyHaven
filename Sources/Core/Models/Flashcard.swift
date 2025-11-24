import Foundation

/// Domain model representing a Flashcard
public struct Flashcard: Identifiable, Codable, Equatable {
    public let id: UUID
    public var classId: UUID
    public var userId: UUID
    public var front: String
    public var back: String
    public var noteIds: [UUID]
    public var lastReviewedAt: Date?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        classId: UUID,
        userId: UUID,
        front: String,
        back: String,
        noteIds: [UUID] = [],
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
