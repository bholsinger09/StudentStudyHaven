import Foundation
import FirebaseAuth

/// Service for Firebase Authentication operations
public class AuthService {
    public static let shared = AuthService()
    
    /// Sign in with email and password
    public func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    /// Create new user with email and password
    public func createUser(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }
    
    /// Sign out current user
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Reset password for email
    public func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Get current user
    public var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Get current user's ID
    public var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// Update user profile
    public func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest?.displayName = displayName
        }
        
        if let photoURL = photoURL {
            changeRequest?.photoURL = photoURL
        }
        
        try await changeRequest?.commitChanges()
    }
}
