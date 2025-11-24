import Foundation

/// Domain model representing a Note
public struct Note: Identifiable, Codable, Equatable {
    public let id: UUID
    public var classId: UUID
    public var userId: UUID
    public var title: String
    public var content: String
    public var linkedNoteIds: [UUID]
    public var tags: [String]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        classId: UUID,
        userId: UUID,
        title: String,
        content: String,
        linkedNoteIds: [UUID] = [],
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.classId = classId
        self.userId = userId
        self.title = title
        self.content = content
        self.linkedNoteIds = linkedNoteIds
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
