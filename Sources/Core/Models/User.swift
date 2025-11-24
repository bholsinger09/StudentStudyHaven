import Foundation

/// Core domain model representing a User in the system
public struct User: Identifiable, Codable, Equatable {
    public let id: UUID
    public var email: String
    public var name: String
    public var collegeId: UUID?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        email: String,
        name: String,
        collegeId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.collegeId = collegeId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
