import Core
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import Foundation

/// Firebase implementation of GroupMessageRepositoryProtocol
/// Handles group messaging using Firestore
public class FirebaseGroupMessageRepositoryImpl: GroupMessageRepositoryProtocol {
    
    private let firestore = Firestore.firestore()
    private let messagesCollection = "groupMessages"
    
    private var listenerRegistration: ListenerRegistration?
    private var messagesSubject = CurrentValueSubject<[GroupMessage], Never>([])
    private var newMessageSubject = PassthroughSubject<GroupMessage, Never>()
    
    public init() {}
    
    // MARK: - GroupMessageRepositoryProtocol Implementation
    
    public func getMessages(for groupId: String, limit: Int?) async throws -> [GroupMessage] {
        do {
            var query: Query = firestore
                .collection(messagesCollection)
                .whereField("studyGroupId", isEqualTo: groupId)
                .order(by: "timestamp", descending: true)
            
            if let limit = limit {
                query = query.limit(to: limit)
            }
            
            let snapshot = try await query.getDocuments()
            
            var messages = try snapshot.documents.compactMap { document in
                try document.data(as: GroupMessage.self)
            }
            
            // Reverse to get chronological order (oldest first)
            messages.reverse()
            
            return messages
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getMessage(by id: String) async throws -> GroupMessage {
        do {
            let document = try await firestore
                .collection(messagesCollection)
                .document(id)
                .getDocument()
            
            guard let message = try? document.data(as: GroupMessage.self) else {
                throw AppError.notFound("Message not found")
            }
            
            return message
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func sendMessage(_ message: GroupMessage) async throws -> GroupMessage {
        do {
            var newMessage = message
            newMessage.timestamp = Date()
            
            let docRef = firestore.collection(messagesCollection).document(newMessage.id)
            try docRef.setData(from: newMessage)
            
            return newMessage
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func updateMessage(_ message: GroupMessage) async throws -> GroupMessage {
        do {
            var updatedMessage = message
            updatedMessage.editedAt = Date()
            
            let docRef = firestore.collection(messagesCollection).document(updatedMessage.id)
            try docRef.setData(from: updatedMessage, merge: true)
            
            return updatedMessage
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func deleteMessage(id: String) async throws {
        do {
            try await firestore
                .collection(messagesCollection)
                .document(id)
                .delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - Real-time Listeners
    
    public func observeMessages(for groupId: String, limit: Int?) -> AnyPublisher<[GroupMessage], Never> {
        var query: Query = firestore
            .collection(messagesCollection)
            .whereField("studyGroupId", isEqualTo: groupId)
            .order(by: "timestamp", descending: false)
        
        if let limit = limit {
            // Get the last N messages by querying in descending order then reversing
            query = firestore
                .collection(messagesCollection)
                .whereField("studyGroupId", isEqualTo: groupId)
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
        }
        
        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else {
                return
            }
            
            var messages = documents.compactMap { document in
                try? document.data(as: GroupMessage.self)
            }
            
            // Reverse to get chronological order if we limited
            if limit != nil {
                messages.reverse()
            }
            
            self?.messagesSubject.send(messages)
        }
        
        return messagesSubject.eraseToAnyPublisher()
    }
    
    public func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never> {
        listenerRegistration = firestore
            .collection(messagesCollection)
            .whereField("studyGroupId", isEqualTo: groupId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot = snapshot else {
                    return
                }
                
                // Only emit new messages (added documents)
                for change in snapshot.documentChanges {
                    if change.type == .added,
                       let message = try? change.document.data(as: GroupMessage.self) {
                        self?.newMessageSubject.send(message)
                    }
                }
            }
        
        return newMessageSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Private Helper Methods
    
    private func mapFirestoreError(_ error: Error) -> AppError {
        if let firestoreError = error as NSError? {
            switch firestoreError.code {
            case FirestoreErrorCode.notFound.rawValue:
                return AppError.notFound("Message not found")
            case FirestoreErrorCode.permissionDenied.rawValue:
                return AppError.unauthorized
            case FirestoreErrorCode.unavailable.rawValue:
                return AppError.networkError("Network unavailable")
            default:
                return AppError.unknown(error.localizedDescription)
            }
        }
        return AppError.unknown(error.localizedDescription)
    }
}
