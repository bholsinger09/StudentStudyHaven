import Foundation

/// REST API-based Firestore User Repository
/// Uses Firebase REST API instead of Firebase SDK
/// NOTE: This implementation is disabled in favor of mock repositories
/// To use: replace DependencyContainer.useMockRepositories = false
@available(*, deprecated, message: "Firebase is currently disabled. Use MockAuthRepositoryImpl instead.")
public class FirebaseRestUserRepository: UserRepositoryProtocol {
    private let restClient: FirebaseRestClient
    private var currentIdToken: String?
    
    public init(restClient: FirebaseRestClient) {
        self.restClient = restClient
    }
    
    /// Set the current auth token (call after login)
    public func setAuthToken(_ token: String) {
        self.currentIdToken = token
    }
    
    public func getUser(by id: String) async throws -> User {
        guard let idToken = currentIdToken else {
            throw AppError.unauthorized
        }
        
        let document = try await restClient.getDocument(path: "users/\(id)", idToken: idToken)
        return try parseUser(from: document)
    }
    
    public func getCurrentUser() async throws -> User? {
        // Get user ID from token (would need to decode JWT in production)
        // For now, we'll rely on the auth repository to provide the user
        return nil
    }
    
    public func updateUser(_ user: User) async throws -> User {
        guard let idToken = currentIdToken else {
            throw AppError.unauthorized
        }
        
        let userData: [String: Any] = [
            "email": user.email,
            "name": user.name,
            "collegeId": user.collegeId ?? "",
            "createdAt": user.createdAt,
            "updatedAt": Date()
        ]
        
        let document = try await restClient.setDocument(
            path: "users/\(user.id)",
            data: userData,
            idToken: idToken
        )
        
        return try parseUser(from: document, id: user.id)
    }
    
    public func deleteUser(id: String) async throws {
        guard let idToken = currentIdToken else {
            throw AppError.unauthorized
        }
        
        try await restClient.deleteDocument(path: "users/\(id)", idToken: idToken)
    }
    
    public func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User] {
        // Note: Firestore REST API doesn't support complex queries easily
        // For production, consider using Firestore's runQuery with proper filters
        return []
    }
    
    public func searchUsersByEmail(email: String, collegeId: String) async throws -> User? {
        // Would need to implement query functionality
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func parseUser(from document: FirestoreDocument, id: String? = nil) throws -> User {
        guard let fields = document.fields else {
            throw AppError.invalidData("Missing document fields")
        }
        
        let userId = id ?? extractUserId(from: document.name)
        
        guard case .stringValue(let email) = fields["email"] else {
            throw AppError.invalidData("Missing email")
        }
        
        guard case .stringValue(let name) = fields["name"] else {
            throw AppError.invalidData("Missing name")
        }
        
        var collegeId: String?
        if case .stringValue(let cid) = fields["collegeId"], !cid.isEmpty {
            collegeId = cid
        }
        
        let createdAt: Date
        if case .timestampValue(let timestamp) = fields["createdAt"] {
            createdAt = ISO8601DateFormatter().date(from: timestamp) ?? Date()
        } else {
            createdAt = Date()
        }
        
        let updatedAt: Date
        if case .timestampValue(let timestamp) = fields["updatedAt"] {
            updatedAt = ISO8601DateFormatter().date(from: timestamp) ?? Date()
        } else {
            updatedAt = Date()
        }
        
        return User(
            id: userId,
            email: email,
            name: name,
            collegeId: collegeId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func extractUserId(from path: String) -> String {
        // Extract ID from path like "projects/.../databases/.../documents/users/USER_ID"
        let components = path.components(separatedBy: "/")
        return components.last ?? ""
    }
}
