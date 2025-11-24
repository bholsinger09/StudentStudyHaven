import Foundation
import Core

/// Use case for user logout
public final class LogoutUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute() async throws {
        try await authRepository.logout()
    }
}
