import Core
import Foundation

#if canImport(UIKit)
import AuthenticationServices
import UIKit

/// Coordinates Sign in with Apple authentication flow
@MainActor
public final class AppleSignInCoordinator: NSObject {
    private let authRepository: AuthRepositoryProtocol
    private var continuation: CheckedContinuation<AuthSession, Error>?

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func signIn() async throws -> AuthSession {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            performSignIn()
        }
    }

    private func performSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppError.authenticationFailed("Invalid Apple ID credential"))
            return
        }

        Task {
            do {
                let userID = appleIDCredential.user
                let email = appleIDCredential.email ?? "\(userID)@appleid.local"
                let fullName = appleIDCredential.fullName?.givenName
                let session = try await authRepository.loginWithAppleID(appleUserID: userID, email: email, fullName: fullName)
                continuation?.resume(returning: session)
            } catch {
                continuation?.resume(throwing: error)
            }
        }
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let appError: Error
        if let asError = error as? ASAuthorizationError {
            let message: String
            switch asError.code {
            case .canceled:
                message = "Sign in with Apple was cancelled"
            case .failed:
                message = "Sign in with Apple failed"
            case .invalidResponse:
                message = "Invalid response from Apple"
            case .notHandled:
                message = "Sign in request not handled"
            case .unknown:
                message = "Unknown error occurred"
            default:
                message = asError.localizedDescription
            }
            appError = AppError.authenticationFailed(message)
        } else {
            appError = error
        }
        continuation?.resume(throwing: appError)
    }

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) {
            return window
        }
        // Fallback for edge cases
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        // Last resort
        return UIWindow()
    }
}

#else
@MainActor
public final class AppleSignInCoordinator {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func signIn() async throws -> AuthSession {
        throw AppError.authenticationFailed("Sign in with Apple is only available on iOS")
    }
}
#endif
