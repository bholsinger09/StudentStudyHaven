import Core
import Combine
import Foundation

/// DEPRECATED: Legacy Firebase SDK implementation
/// This file is kept for compatibility but is no longer used.
/// Use REST API implementation instead.
public class FirebaseGroupMessageRepositoryImpl: GroupMessageRepositoryProtocol {
    
    private var messagesSubject = CurrentValueSubject<[GroupMessage], Never>([])
    private var newMessageSubject = PassthroughSubject<GroupMessage, Never>()
    
    public init() {}
    
    // MARK: - GroupMessageRepositoryProtocol Implementation
    
    public func getMessages(for groupId: String, limit: Int?) async throws -> [GroupMessage] {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func getMessage(by id: String) async throws -> GroupMessage {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func deleteMessage(id: String) async throws {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    // MARK: - Real-time Listeners
    
    public func observeMessages(for groupId: String, limit: Int?) -> AnyPublisher<[GroupMessage], Never> {
        return messagesSubject.eraseToAnyPublisher()
    }
    
    public func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        return newMessageSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        // No-op
    }
}
