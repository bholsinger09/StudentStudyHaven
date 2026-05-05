import Core
import Foundation

/// REST API-based Firebase Auth implementation
/// Uses Firebase REST API instead of Firebase SDK (no binary dependencies!)
public class FirebaseRestAuthRepository: AuthRepositoryProtocol {
    private let restClient: FirebaseRestClient
    private let userRepository: UserRepositoryProtocol
    
    private var currentIdToken: String?
    private var currentRefreshToken: String?
    private var currentUserId: String?
    private var tokenExpirationDate: Date?
    
    public init(restClient: FirebaseRestClient, userRepository: UserRepositoryProtocol) {
        self.restClient = restClient
        self.userRepository = userRepository
        
        // Restore session from UserDefaults
        restoreSession()
    }
    
    public func login(credentials: LoginCredentials) async throws -> AuthSession {
        let authResponse = try await restClient.signIn(email: credentials.email, password: credentials.password)
        
        // Store tokens
        currentIdToken = authResponse.idToken
        currentRefreshToken = authResponse.refreshToken
        currentUserId = authResponse.localId
        tokenExpirationDate = Date().addingTimeInterval(Double(authResponse.expiresIn) ?? 3600)
        
        saveSession()
        
        // Get or create user profile
        let user = try await getOrCreateUser(userId: authResponse.localId, email: credentials.email)
        
        return AuthSession(
            user: user,
            token: authResponse.idToken,
            expiresAt: tokenExpirationDate ?? Date().addingTimeInterval(3600)
        )
    }
    
    public func register(data: RegistrationData) async throws -> AuthSession {
        // Create auth account
        let authResponse = try await restClient.signUp(email: data.email, password: data.password)
        
        // Store tokens
        currentIdToken = authResponse.idToken
        currentRefreshToken = authResponse.refreshToken
        currentUserId = authResponse.localId
        tokenExpirationDate = Date().addingTimeInterval(Double(authResponse.expiresIn) ?? 3600)
        
        saveSession()
        
        // Create user profile in Firestore
        let user = User(
            id: authResponse.localId,
            email: data.email,
            name: data.name,
            collegeId: data.collegeId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let createdUser = try await userRepository.updateUser(user)
        
        return AuthSession(
            user: createdUser,
            token: authResponse.idToken,
            expiresAt: tokenExpirationDate ?? Date().addingTimeInterval(3600)
        )
    }
    
    public func logout() async throws {
        currentIdToken = nil
        currentRefreshToken = nil
        currentUserId = nil
        tokenExpirationDate = nil
        
        clearSession()
    }
    
    public func getCurrentSession() async -> AuthSession? {
        guard let idToken = currentIdToken,
              let userId = currentUserId,
              let expirationDate = tokenExpirationDate else {
            return nil
        }
        
        // Check if token is expired
        if Date() >= expirationDate {
            // Try to refresh
            if let refreshedSession = try? await refreshToken() {
                return refreshedSession
            }
            return nil
        }
        
        // Get user profile
        guard let user = try? await userRepository.getUser(by: userId) else {
            return nil
        }
        
        return AuthSession(
            user: user,
            token: idToken,
            expiresAt: expirationDate
        )
    }
    
    public func refreshToken() async throws -> AuthSession {
        guard let refreshToken = currentRefreshToken else {
            throw AppError.unauthorized
        }
        
        let response = try await restClient.refreshToken(refreshToken)
        
        // Update tokens
        currentIdToken = response.id_token
        currentRefreshToken = response.refresh_token
        currentUserId = response.user_id
        tokenExpirationDate = Date().addingTimeInterval(Double(response.expires_in) ?? 3600)
        
        saveSession()
        
        // Get user profile
        let user = try await userRepository.getUser(by: response.user_id)
        
        return AuthSession(
            user: user,
            token: response.id_token,
            expiresAt: tokenExpirationDate ?? Date().addingTimeInterval(3600)
        )
    }
    
    // MARK: - Helper Methods
    
    private func getOrCreateUser(userId: String, email: String) async throws -> User {
        // Try to get existing user
        if let existingUser = try? await userRepository.getUser(by: userId) {
            return existingUser
        }
        
        // Create new user profile
        let user = User(
            id: userId,
            email: email,
            name: email.components(separatedBy: "@").first ?? "User",
            collegeId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        return try await userRepository.updateUser(user)
    }
    
    // MARK: - Session Persistence
    
    private func saveSession() {
        let defaults = UserDefaults.standard
        defaults.set(currentIdToken, forKey: "firebase_id_token")
        defaults.set(currentRefreshToken, forKey: "firebase_refresh_token")
        defaults.set(currentUserId, forKey: "firebase_user_id")
        defaults.set(tokenExpirationDate, forKey: "firebase_token_expiration")
    }
    
    private func restoreSession() {
        let defaults = UserDefaults.standard
        currentIdToken = defaults.string(forKey: "firebase_id_token")
        currentRefreshToken = defaults.string(forKey: "firebase_refresh_token")
        currentUserId = defaults.string(forKey: "firebase_user_id")
        tokenExpirationDate = defaults.object(forKey: "firebase_token_expiration") as? Date
    }
    
    private func clearSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "firebase_id_token")
        defaults.removeObject(forKey: "firebase_refresh_token")
        defaults.removeObject(forKey: "firebase_user_id")
        defaults.removeObject(forKey: "firebase_token_expiration")
    }
}
