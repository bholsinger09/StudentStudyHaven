import Combine
import Foundation

/// Protocol for real-time data listeners
public protocol RealtimeListener {
    associatedtype T
    func startListening() async throws
    func stopListening()
    var publisher: AnyPublisher<[T], Never> { get }
}

/// Represents the state of a real-time connection
public enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    public static func == (lhs: ConnectionState, rhs: ConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
            (.connecting, .connecting),
            (.connected, .connected):
            return true
        case let (.error(lhsMsg), .error(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

/// Real-time change type
public enum ChangeType {
    case added
    case modified
    case removed
}

/// Represents a change event in real-time data
public struct DataChange<T> {
    public let type: ChangeType
    public let item: T
    public let timestamp: Date

    public init(type: ChangeType, item: T, timestamp: Date = Date()) {
        self.type = type
        self.item = item
        self.timestamp = timestamp
    }
}
