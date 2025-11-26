import XCTest

@testable import Authentication
@testable import Core

final class LoginUseCaseTests: XCTestCase {
    var mockRepository: MockAuthRepository!
    var sut: LoginUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        sut = LoginUseCase(authRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testLoginWithValidCredentials() async throws {
        // Given
        let credentials = LoginCredentials(
            email: "test@example.com",
            password: "password123"
        )
        let expectedUser = User(email: credentials.email, name: "Test User")
        mockRepository.loginResult = .success(
            AuthSession(
                user: expectedUser,
                token: "test-token",
                expiresAt: Date().addingTimeInterval(3600)
            ))

        // When
        let session = try await sut.execute(credentials: credentials)

        // Then
        XCTAssertEqual(session.user.email, credentials.email)
        XCTAssertEqual(mockRepository.loginCallCount, 1)
    }

    func testLoginWithEmptyEmail() async {
        // Given
        let credentials = LoginCredentials(email: "", password: "password123")

        // When/Then
        do {
            _ = try await sut.execute(credentials: credentials)
            XCTFail("Should throw error for empty email")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("Email"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func testLoginWithEmptyPassword() async {
        // Given
        let credentials = LoginCredentials(email: "test@example.com", password: "")

        // When/Then
        do {
            _ = try await sut.execute(credentials: credentials)
            XCTFail("Should throw error for empty password")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("Password"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func testLoginWithInvalidEmailFormat() async {
        // Given
        let credentials = LoginCredentials(email: "invalid-email", password: "password123")

        // When/Then
        do {
            _ = try await sut.execute(credentials: credentials)
            XCTFail("Should throw error for invalid email format")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("email"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Mock Repository
class MockAuthRepository: AuthRepositoryProtocol {
    var loginCallCount = 0
    var registerCallCount = 0
    var logoutCallCount = 0

    var loginResult: Result<AuthSession, Error> = .failure(AppError.unknown("Not configured"))
    var registerResult: Result<AuthSession, Error> = .failure(AppError.unknown("Not configured"))

    func login(credentials: LoginCredentials) async throws -> AuthSession {
        loginCallCount += 1
        return try loginResult.get()
    }

    func register(data: RegistrationData) async throws -> AuthSession {
        registerCallCount += 1
        return try registerResult.get()
    }

    func logout() async throws {
        logoutCallCount += 1
    }

    func getCurrentSession() async -> AuthSession? {
        return nil
    }

    func refreshToken() async throws -> AuthSession {
        throw AppError.unknown("Not implemented")
    }
    
    func deleteAccount() async throws {
        // Mock implementation
    }
}
