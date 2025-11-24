import Foundation
import Core

/// Protocol for Authentication Repository
public protocol AuthRepositoryProtocol {
    func login(credentials: LoginCredentials) async throws -> AuthSession
    func register(data: RegistrationData) async throws -> AuthSession
    func logout() async throws
    func getCurrentSession() async -> AuthSession?
    func refreshToken() async throws -> AuthSession
}
