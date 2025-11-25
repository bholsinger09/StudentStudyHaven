import Foundation

/// Domain model representing a College/University
public struct College: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var location: String
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        location: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.createdAt = createdAt
    }
}
