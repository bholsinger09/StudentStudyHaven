import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of GroupMessageRepositoryProtocol
/// Uses Apple's native CloudKit for group message data persistence
public class CloudKitGroupMessageRepositoryImpl: GroupMessageRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.groupMessage.rawValue
    
    // Cache for in-memory storage
    private var messageCache: [String: GroupMessage] = [:]
    private var messagesForGroupCache: [String: [GroupMessage]] = [:]
    private var updateSubject = PassthroughSubject<GroupMessage, Never>()
    private var messagesSubject = PassthroughSubject<[GroupMessage], Never>()
    
    public init() {
        // Subscribe to message changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch messages for a group with optional limit
    public func getMessages(for groupId: String, limit: Int? = nil) async throws -> [GroupMessage] {
        let predicate = NSPredicate(format: "groupId == %@", groupId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        var messages = records.compactMap { record in
            GroupMessage.fromCKRecord(record)
        }
        
        // Sort by timestamp descending
        messages.sort { $0.timestamp > $1.timestamp }
        
        // Apply limit if provided
        if let limit = limit {
            messages = Array(messages.prefix(limit))
        }
        
        // Cache them
        messages.forEach { message in
            messageCache[message.id] = message
        }
        messagesForGroupCache[groupId] = messages
        
        return messages
    }
    
    /// Fetch a single message by ID
    public func getMessage(by id: String) async throws -> GroupMessage {
        // Check cache first
        if let cached = messageCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let message = GroupMessage.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        messageCache[id] = message
        return message
    }
    
    /// Send a new message
    public func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        let record = message.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        messageCache[message.id] = message
        
        // Notify subscribers
        updateSubject.send(message)
        
        return message
    }
    
    /// Update an existing message
    public func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        let record = message.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        messageCache[message.id] = message
        
        // Notify subscribers
        messagesSubject.send([message])
        
        return message
    }
    
    /// Delete a message
    public func deleteMessage(id: String) async throws {
        if messageCache[id] == nil {
            _ = try await getMessage(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        messageCache.removeValue(forKey: id)
    }
    
    // MARK: - Observers
    
    /// Observe messages for a group
    public func observeMessages(for groupId: String, limit: Int? = nil) -> AnyPublisher<[GroupMessage], Never> {
        // Return cached messages immediately
        if let cached = messagesForGroupCache[groupId] {
            var result = cached
            if let limit = limit {
                result = Array(result.prefix(limit))
            }
            messagesSubject.send(result)
        }
        
        return messagesSubject.eraseToAnyPublisher()
    }
    
    /// Observe new messages for a group (real-time)
    public func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        messageCache.removeAll()
        messagesForGroupCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension GroupMessage {
    /// Convert GroupMessage to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.groupMessage.rawValue, recordID: recordID)
        
        record["id"] = id
        record["studyGroupId"] = studyGroupId
        record["senderId"] = senderId
        record["senderName"] = senderName
        record["content"] = content
        record["messageType"] = messageType.rawValue
        record["isEdited"] = NSNumber(value: isEdited)
        record["timestamp"] = timestamp
        
        if let editedAt = editedAt {
            record["editedAt"] = editedAt
        }
        
        return record
    }
    
    /// Create GroupMessage from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> GroupMessage? {
        let id = record.recordID.recordName
        guard let studyGroupId = record["studyGroupId"] as? String,
              let senderId = record["senderId"] as? String,
              let senderName = record["senderName"] as? String,
              let content = record["content"] as? String,
              let messageTypeString = record["messageType"] as? String,
              let messageType = GroupMessage.MessageType(rawValue: messageTypeString),
              let isEdited = record["isEdited"] as? NSNumber,
              let timestamp = record["timestamp"] as? Date else {
            return nil
        }
        
        let editedAt = record["editedAt"] as? Date
        
        return GroupMessage(
            id: id,
            studyGroupId: studyGroupId,
            senderId: senderId,
            senderName: senderName,
            content: content,
            messageType: messageType,
            timestamp: timestamp,
            isEdited: isEdited.boolValue,
            editedAt: editedAt
        )
    }
}
