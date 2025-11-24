import Foundation
import Core
import Combine

/// ViewModel for Login screen
@MainActor
public final class LoginViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isLoggedIn: Bool = false
    
    private let loginUseCase: LoginUseCase
    
    public init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    public func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let credentials = LoginCredentials(email: email, password: password)
            _ = try await loginUseCase.execute(credentials: credentials)
            isLoggedIn = true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    public func clearError() {
        errorMessage = nil
    }
}
