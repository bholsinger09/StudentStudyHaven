import Foundation
import FirebaseFirestore

/// Service for Firestore database operations
public class DatabaseService {
    public static let shared = DatabaseService()
    
    private let db = Firestore.firestore()
    
    // MARK: - Generic CRUD Operations
    
    /// Create or update a document
    public func set<T: Encodable>(
        _ value: T,
        at path: String,
        merge: Bool = true
    ) async throws {
        let data = try FirestoreHelper.encode(value)
        try await db.document(path).setData(data, merge: merge)
    }
    
    /// Get a single document
    public func get<T: Decodable>(
        from path: String,
        as type: T.Type
    ) async throws -> T {
        let document = try await db.document(path).getDocument()
        
        guard let data = document.data() else {
            throw FirestoreError.documentNotFound
        }
        
        return try FirestoreHelper.decode(data, to: type)
    }
    
    /// Query documents from a collection
    public func query<T: Decodable>(
        _ collection: String,
        where predicates: [(String, Any)]? = nil,
        orderBy: String? = nil,
        descending: Bool = false,
        limit: Int? = nil,
        as type: T.Type
    ) async throws -> [T] {
        var query: Query = db.collection(collection)
        
        // Apply predicates
        if let predicates = predicates {
            for (field, value) in predicates {
                query = query.whereField(field, isEqualTo: value)
            }
        }
        
        // Apply ordering
        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }
        
        // Apply limit
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return try snapshot.documents.map { doc in
            try FirestoreHelper.decode(doc.data(), to: type)
        }
    }
    
    /// Delete a document
    public func delete(at path: String) async throws {
        try await db.document(path).delete()
    }
    
    /// Update specific fields in a document
    public func update(_ path: String, with data: [String: Any]) async throws {
        try await db.document(path).updateData(data)
    }
    
    // MARK: - Batch Operations
    
    /// Perform a batch write operation
    public func batch(_ operations: (WriteBatch) -> Void) async throws {
        let batch = db.batch()
        operations(batch)
        try await batch.commit()
    }
    
    // MARK: - Real-time Listeners
    
    /// Listen to document changes
    public func listenToDocument<T: Decodable>(
        at path: String,
        as type: T.Type,
        onUpdate: @escaping (T) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        return db.document(path).addSnapshotListener { snapshot, error in
            if let error = error {
                onError(error)
                return
            }
            
            guard let data = snapshot?.data() else {
                onError(FirestoreError.documentNotFound)
                return
            }
            
            do {
                let decoded = try FirestoreHelper.decode(data, to: type)
                onUpdate(decoded)
            } catch {
                onError(error)
            }
        }
    }
    
    /// Listen to collection changes
    public func listenToCollection<T: Decodable>(
        _ collection: String,
        as type: T.Type,
        onUpdate: @escaping ([T]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        return db.collection(collection).addSnapshotListener { snapshot, error in
            if let error = error {
                onError(error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                onError(FirestoreError.documentNotFound)
                return
            }
            
            do {
                let decoded = try documents.map { doc in
                    try FirestoreHelper.decode(doc.data(), to: type)
                }
                onUpdate(decoded)
            } catch {
                onError(error)
            }
        }
    }
}
