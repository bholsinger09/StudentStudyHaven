import XCTest
import Combine
@testable import Core

/// Mock implementation of GroupMessageRepositoryProtocol for testing
class MockGroupMessageRepository: GroupMessageRepositoryProtocol {
    var messages: [GroupMessage] = []
    var error: Error?
    var sendMessageCallCount = 0
    
    func getMessages(for groupId: String, limit: Int?) async throws -> [GroupMessage] {
        if let error = error { throw error }
        var filtered = messages.filter { $0.studyGroupId == groupId }
            .sorted { $0.timestamp > $1.timestamp }
        if let limit = limit {
            filtered = Array(filtered.prefix(limit))
        }
        return filtered
    }
    
    func getMessage(by id: String) async throws -> GroupMessage {
        if let error = error { throw error }
        guard let message = messages.first(where: { $0.id == id }) else {
            throw AppError.notFound("Message not found")
        }
        return message
    }
    
    func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        sendMessageCallCount += 1
        if let error = error { throw error }
        messages.append(message)
        return message
    }
    
    func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        if let error = error { throw error }
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
            return message
        }
        throw AppError.notFound("Message not found")
    }
    
    func deleteMessage(id: String) async throws {
        if let error = error { throw error }
        messages.removeAll { $0.id == id }
    }
    
    func observeMessages(for groupId: String, limit: Int?) -> AnyPublisher<[GroupMessage], Never> {
        fatalError("Not implemented in mock")
    }
    
    func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        fatalError("Not implemented in mock")
    }
    
    func stopObserving() {
        // No-op for mock
    }
}
