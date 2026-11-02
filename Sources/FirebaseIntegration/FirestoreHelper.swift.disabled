import Foundation
import FirebaseFirestore

/// Helper utilities for Firestore operations
public class FirestoreHelper {
    
    /// Reference to Firestore database
    public static let db = Firestore.firestore()
    
    // MARK: - Collection References
    
    public static var studyGroupsCollection: CollectionReference {
        return db.collection("studyGroups")
    }
    
    public static var classesCollection: CollectionReference {
        return db.collection("classes")
    }
    
    public static var flashcardsCollection: CollectionReference {
        return db.collection("flashcards")
    }
    
    public static var notesCollection: CollectionReference {
        return db.collection("notes")
    }
    
    public static var gradesCollection: CollectionReference {
        return db.collection("grades")
    }
    
    public static var usersCollection: CollectionReference {
        return db.collection("users")
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    /// Encode an object to Firestore-compatible dictionary
    public static func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirestoreError.encodingFailed
        }
        return dict
    }
    
    /// Decode a Firestore document to a model
    public static func decode<T: Decodable>(_ data: [String: Any], to type: T.Type) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(type, from: jsonData)
    }
}

// MARK: - Error Handling

public enum FirestoreError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case documentNotFound
    case operationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode object for Firestore"
        case .decodingFailed:
            return "Failed to decode object from Firestore"
        case .documentNotFound:
            return "Document not found"
        case .operationFailed(let message):
            return "Firestore operation failed: \(message)"
        }
    }
}
