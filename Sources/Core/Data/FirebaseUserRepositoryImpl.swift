import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

/// Firebase implementation of UserRepositoryProtocol
/// Handles user management and search using Firestore
public class FirebaseUserRepositoryImpl: UserRepositoryProtocol {
    
    private let firestore = Firestore.firestore()
    private let usersCollection = "users"
    
    public init() {}
    
    // MARK: - UserRepositoryProtocol Implementation
    
    public func getUser(by id: String) async throws -> User {
        do {
            let document = try await firestore
                .collection(usersCollection)
                .document(id)
                .getDocument()
            
            guard let user = try? document.data(as: User.self) else {
                throw AppError.notFound("User not found")
            }
            
            return user
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func getCurrentUser() async throws -> User? {
        // This would typically get the current authenticated user from Firebase Auth
        // For now, returning nil as this should be handled by AuthRepository
        return nil
    }
    
    public func updateUser(_ user: User) async throws -> User {
        do {
            var updatedUser = user
            updatedUser.updatedAt = Date()
            
            let docRef = firestore.collection(usersCollection).document(updatedUser.id)
            try docRef.setData(from: updatedUser, merge: true)
            
            return updatedUser
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func deleteUser(id: String) async throws {
        do {
            try await firestore
                .collection(usersCollection)
                .document(id)
                .delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - User Search Functionality
    
    public func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User] {
        do {
            // Firestore doesn't support full-text search or compound queries with inequality on multiple fields
            // We'll search by email first (which should be unique), then filter by name
            let emailLowercase = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let nameLowercase = firstName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Search by email in the college
            let snapshot = try await firestore
                .collection(usersCollection)
                .whereField("email", isEqualTo: emailLowercase)
                .whereField("collegeId", isEqualTo: collegeId)
                .limit(to: 10)
                .getDocuments()
            
            var users = try snapshot.documents.compactMap { document in
                try document.data(as: User.self)
            }
            
            // Filter by first name on the client side
            users = users.filter { user in
                let userFirstName = user.name.components(separatedBy: " ").first?.lowercased() ?? ""
                return userFirstName.contains(nameLowercase) || nameLowercase.contains(userFirstName)
            }
            
            return users
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func searchUsersByEmail(email: String, collegeId: String) async throws -> User? {
        do {
            let emailLowercase = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            let snapshot = try await firestore
                .collection(usersCollection)
                .whereField("email", isEqualTo: emailLowercase)
                .whereField("collegeId", isEqualTo: collegeId)
                .limit(to: 1)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                return nil
            }
            
            return try document.data(as: User.self)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func mapFirestoreError(_ error: Error) -> AppError {
        if let firestoreError = error as NSError? {
            switch firestoreError.code {
            case FirestoreErrorCode.notFound.rawValue:
                return AppError.notFound("User not found")
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
