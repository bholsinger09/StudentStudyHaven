import Authentication
import Core
import Foundation

/// Use case for resetting user password via email
public struct ResetPasswordUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(email: String) async throws {
        // Validate email format
        guard isValidEmail(email) else {
            throw AppError.invalidData("Please enter a valid email address")
        }
        
        // Send password reset email via Firebase Auth
        // TODO: Implement sendPasswordResetEmail in AuthRepositoryProtocol
        // try await authRepository.sendPasswordResetEmail(email: email)
        
        // For now, simulate success
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
