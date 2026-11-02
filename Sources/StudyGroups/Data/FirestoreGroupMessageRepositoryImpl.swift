import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of GroupMessageRepositoryProtocol
/// Manages messages for group study sessions
public class FirestoreGroupMessageRepositoryImpl: GroupMessageRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "groupMessages"
    private var listenerRegistrations: [ListenerRegistration] = []
    private var newMessagesStartTime = Date()
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch messages for a group with optional limit
    /// NOTE: Limit applied client-side after fetching all messages
    public func getMessages(for groupId: String, limit: Int? = nil) async throws -> [GroupMessage] {
        let messages = try await database.query(
            collectionName,
            where: [("studyGroupId", groupId)],
            as: GroupMessage.self
        )
        
        // Sort by timestamp descending (newest first)
        let sorted = messages.sorted { $0.timestamp > $1.timestamp }
        
        // Apply limit if provided
        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }
    
    /// Fetch a single message by ID
    public func getMessage(by id: String) async throws -> GroupMessage {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: GroupMessage.self)
    }
    
    /// Send a message (create with server timestamp)
    public func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        let path = "\(collectionName)/\(message.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(message),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
        }
        
        // Use server timestamp instead of client timestamp
        dict["timestamp"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return message
    }
    
    /// Update a message
    public func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        let path = "\(collectionName)/\(message.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(message),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode message"])
        }
        
        // Mark as edited
        dict["isEdited"] = true
        dict["editedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return message
    }
    
    /// Delete a message
    public func deleteMessage(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all messages for a group with optional limit
    /// NOTE: Limit applied client-side; all messages fetched then sliced
    public func observeMessages(for groupId: String, limit: Int? = nil) -> AnyPublisher<[GroupMessage], Never> {
        let subject = CurrentValueSubject<[GroupMessage], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: GroupMessage.self,
            onUpdate: { messages in
                // Filter messages for this group
                let filtered = messages.filter { $0.studyGroupId == groupId }
                
                // Sort by timestamp descending (newest first)
                let sorted = filtered.sorted { $0.timestamp > $1.timestamp }
                
                // Apply limit if provided
                let result = limit.map { Array(sorted.prefix($0)) } ?? sorted
                subject.send(result)
            },
            onError: { error in
                print("❌ Error observing messages: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe new messages only (sent after this listener was registered)
    /// Emits individual messages as they arrive
    public func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        let subject = PassthroughSubject<GroupMessage, Never>()
        
        // Capture the current time as the cutoff for "new" messages
        let cutoffTime = Date()
        
        let listener = database.listenToCollection(
            collectionName,
            as: GroupMessage.self,
            onUpdate: { messages in
                // Filter for this group and only messages after cutoff time
                let newMessages = messages.filter { message in
                    message.studyGroupId == groupId && message.timestamp > cutoffTime
                }
                
                // Emit each new message
                newMessages.forEach { subject.send($0) }
            },
            onError: { error in
                print("❌ Error observing new messages: \(error)")
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Stop all real-time listeners
    public func stopObserving() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
    
    deinit {
        stopObserving()
    }
}
