import Foundation
import Core

/// Use case for user login
public final class LoginUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(credentials: LoginCredentials) async throws -> AuthSession {
        // Validate credentials
        guard !credentials.email.isEmpty else {
            throw AppError.invalidData("Email cannot be empty")
        }
        
        guard !credentials.password.isEmpty else {
            throw AppError.invalidData("Password cannot be empty")
        }
        
        guard isValidEmail(credentials.email) else {
            throw AppError.invalidData("Invalid email format")
        }
        
        // Attempt login
        return try await authRepository.login(credentials: credentials)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
