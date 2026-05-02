import Foundation

/// Domain model representing a Study Group
public struct StudyGroup: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var classId: String
    public var collegeId: String
    public var description: String?
    public var createdBy: String // userId
    public var memberIds: [String]
    public var maxMembers: Int?
    public var isPublic: Bool // Public groups can be discovered, private require invite
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        classId: String,
        collegeId: String,
        description: String? = nil,
        createdBy: String,
        memberIds: [String] = [],
        maxMembers: Int? = nil,
        isPublic: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.classId = classId
        self.collegeId = collegeId
        self.description = description
        self.createdBy = createdBy
        self.memberIds = memberIds
        self.maxMembers = maxMembers
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Check if group is full
    public var isFull: Bool {
        guard let max = maxMembers else { return false }
        return memberIds.count >= max
    }
    
    /// Check if user is a member
    public func isMember(_ userId: String) -> Bool {
        return memberIds.contains(userId)
    }
    
    /// Check if user is the creator
    public func isCreator(_ userId: String) -> Bool {
        return createdBy == userId
    }
}
