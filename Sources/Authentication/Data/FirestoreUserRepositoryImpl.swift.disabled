import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of UserRepositoryProtocol
/// Handles user CRUD and authentication context
/// Located in Authentication module to avoid circular dependencies
public class FirestoreUserRepositoryImpl: UserRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "users"
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch a user by ID
    public func getUser(by id: String) async throws -> User {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: User.self)
    }
    
    /// Get the currently authenticated user
    /// Returns nil if no user is authenticated
    /// NOTE: Uses AuthService to get current user context
    public func getCurrentUser() async throws -> User? {
        // AuthService is in FirebaseIntegration module and has access to Auth
        let authService = AuthService.shared
        
        if let currentUserID = authService.currentUserID {
            return try await getUser(by: currentUserID)
        }
        
        return nil
    }
    
    /// Update a user
    public func updateUser(_ user: User) async throws -> User {
        let path = "\(collectionName)/\(user.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(user),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode user"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return user
    }
    
    /// Delete a user
    public func deleteUser(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    // MARK: - Search Operations
    
    /// Search for users by firstName, email, and collegeId
    /// NOTE: Firestore doesn't support partial string matching natively.
    /// This implementation filters client-side after fetching by collegeId.
    public func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User] {
        // Query by collegeId (the only field we can efficiently filter)
        let users = try await database.query(
            collectionName,
            where: [("collegeId", collegeId)],
            as: User.self
        )
        
        // Filter client-side for firstName and email matches
        let searchFirstName = firstName.lowercased()
        let searchEmail = email.lowercased()
        
        return users.filter { user in
            let nameMatch = searchFirstName.isEmpty || user.name.lowercased().contains(searchFirstName)
            let emailMatch = searchEmail.isEmpty || user.email.lowercased().contains(searchEmail)
            return nameMatch && emailMatch
        }
    }
    
    /// Search for a user by exact email in a college
    public func searchUsersByEmail(email: String, collegeId: String) async throws -> User? {
        let users = try await database.query(
            collectionName,
            where: [("collegeId", collegeId)],
            as: User.self
        )
        
        // Find exact email match
        return users.first { $0.email.lowercased() == email.lowercased() }
    }
}
