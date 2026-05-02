import Foundation

/// Domain model representing a message in a Study Group chat
public struct GroupMessage: Identifiable, Codable, Equatable {
    public let id: String
    public var studyGroupId: String
    public var senderId: String
    public var senderName: String // Denormalized for UI performance
    public var content: String
    public var messageType: MessageType
    public var timestamp: Date
    public var isEdited: Bool
    public var editedAt: Date?
    
    public enum MessageType: String, Codable, Equatable {
        case text
        case sessionAnnouncement
        case memberJoined
        case memberLeft
        case system
    }
    
    public init(
        id: String = UUID().uuidString,
        studyGroupId: String,
        senderId: String,
        senderName: String,
        content: String,
        messageType: MessageType = .text,
        timestamp: Date = Date(),
        isEdited: Bool = false,
        editedAt: Date? = nil
    ) {
        self.id = id
        self.studyGroupId = studyGroupId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.messageType = messageType
        self.timestamp = timestamp
        self.isEdited = isEdited
        self.editedAt = editedAt
    }
    
    /// Check if message was sent by user
    public func isSentBy(_ userId: String) -> Bool {
        return senderId == userId
    }
}
