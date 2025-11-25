import Foundation

/// Domain model representing a Note
public struct Note: Identifiable, Codable, Equatable {
    public let id: String
    public var classId: String
    public var userId: String
    public var title: String
    public var content: String
    public var linkedNoteIds: [String]
    public var tags: [String]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        classId: String,
        userId: String,
        title: String,
        content: String,
        linkedNoteIds: [String] = [],
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
