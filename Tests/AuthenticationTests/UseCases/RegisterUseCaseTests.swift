import XCTest
@testable import Authentication
@testable import Core

final class RegisterUseCaseTests: XCTestCase {
    var mockRepository: MockAuthRepository!
    var sut: RegisterUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        sut = RegisterUseCase(authRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testRegisterWithValidData() async throws {
        // Given
        let data = RegistrationData(
            email: "test@example.com",
            password: "password123",
            name: "Test User"
        )
        let expectedUser = User(email: data.email, name: data.name)
        mockRepository.registerResult = .success(AuthSession(
            user: expectedUser,
            token: "test-token",
            expiresAt: Date().addingTimeInterval(3600)
        ))
        
        // When
        let session = try await sut.execute(data: data)
        
        // Then
        XCTAssertEqual(session.user.email, data.email)
        XCTAssertEqual(session.user.name, data.name)
        XCTAssertEqual(mockRepository.registerCallCount, 1)
    }
    
    func testRegisterWithEmptyEmail() async {
        // Given
        let data = RegistrationData(
            email: "",
            password: "password123",
            name: "Test User"
        )
        
        // When/Then
        do {
            _ = try await sut.execute(data: data)
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
    
    func testRegisterWithShortPassword() async {
        // Given
        let data = RegistrationData(
            email: "test@example.com",
            password: "short",
            name: "Test User"
        )
        
        // When/Then
        do {
            _ = try await sut.execute(data: data)
            XCTFail("Should throw error for short password")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("8 characters"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testRegisterWithEmptyName() async {
        // Given
        let data = RegistrationData(
            email: "test@example.com",
            password: "password123",
            name: ""
        )
        
        // When/Then
        do {
            _ = try await sut.execute(data: data)
            XCTFail("Should throw error for empty name")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("Name"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
    
    func testRegisterWithInvalidEmailFormat() async {
        // Given
        let data = RegistrationData(
            email: "invalid-email",
            password: "password123",
            name: "Test User"
        )
        
        // When/Then
        do {
            _ = try await sut.execute(data: data)
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
