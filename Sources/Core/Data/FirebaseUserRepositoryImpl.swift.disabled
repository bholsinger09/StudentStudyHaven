import Foundation
import Combine

/// DEPRECATED: Legacy Firebase SDK implementation
/// This file is kept for compatibility but is no longer used.
/// Use FirebaseRestUserRepository for the REST API implementation.
public class FirebaseUserRepositoryImpl: UserRepositoryProtocol {
    
    public init() {}
    
    // MARK: - UserRepositoryProtocol Implementation
    
    public func getUser(by id: String) async throws -> User {
        throw AppError.unknown("Firebase SDK implementation is deprecated. Use FirebaseRestUserRepository instead.")
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func updateUser(_ user: User) async throws -> User {
        throw AppError.unknown("Firebase SDK implementation is deprecated. Use FirebaseRestUserRepository instead.")
    }
    
    public func deleteUser(id: String) async throws {
        throw AppError.unknown("Firebase SDK implementation is deprecated. Use FirebaseRestUserRepository instead.")
    }
    
    // MARK: - User Search Functionality
    
    public func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User] {
        throw AppError.unknown("Firebase SDK implementation is deprecated. Use FirebaseRestUserRepository instead.")
    }
    
    public func searchUsersByEmail(email: String, collegeId: String) async throws -> User? {
        throw AppError.unknown("Firebase SDK implementation is deprecated. Use FirebaseRestUserRepository instead.")
    }
}
