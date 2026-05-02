import Combine
import Core
import Foundation

/// Mock implementation of GroupMessageRepository for development and testing
public final class MockGroupMessageRepositoryImpl: GroupMessageRepositoryProtocol {
    private var messages: [String: GroupMessage] = [:]
    private let messagesSubject = CurrentValueSubject<[GroupMessage], Never>([])
    private let newMessageSubject = PassthroughSubject<GroupMessage, Never>(

)
    private var isObserving = false
    
    public init() {}
    
    public func getMessages(for groupId: String, limit: Int?) async throws -> [GroupMessage] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        var filtered = messages.values.filter { $0.studyGroupId == groupId }
            .sorted { $0.timestamp > $1.timestamp }
        
        if let limit = limit {
            filtered = Array(filtered.prefix(limit))
        }
        
        return filtered
    }
    
    public func getMessage(by id: String) async throws -> GroupMessage {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let message = messages[id] else {
            throw AppError.notFound( "Message not found")
        }
        
        return message
    }
    
    public func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        messages[message.id] = message
        
        if isObserving {
            newMessageSubject.send(message)
            updateMessagesSubject()
        }
        
        return message
    }
    
    public func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard messages[message.id] != nil else {
            throw AppError.notFound("Message not found")
        }
        
        var updatedMessage = message
        updatedMessage.isEdited = true
        updatedMessage.editedAt = Date()
        messages[message.id] = updatedMessage
        
        if isObserving {
            updateMessagesSubject()
        }
        
        return updatedMessage
    }
    
    public func deleteMessage(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard messages[id] != nil else {
            throw AppError.notFound("Message not found")
        }
        
        messages.removeValue(forKey: id)
        
        if isObserving {
            updateMessagesSubject()
        }
    }
    
    // MARK: - Real-time listeners
    
    public func observeMessages(for groupId: String, limit: Int?) -> AnyPublisher<[GroupMessage], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialMessages = try await getMessages(for: groupId, limit: limit)
                messagesSubject.send(initialMessages)
            } catch {
                messagesSubject.send([])
            }
        }
        return messagesSubject.eraseToAnyPublisher()
    }
    
    public func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        isObserving = true
        return newMessageSubject
            .filter { $0.studyGroupId == groupId }
            .eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        isObserving = false
    }
    
    // MARK: - Private helpers
    
    private func updateMessagesSubject() {
        let allMessages = Array(messages.values).sorted { $0.timestamp > $1.timestamp }
        messagesSubject.send(allMessages)
    }
}
