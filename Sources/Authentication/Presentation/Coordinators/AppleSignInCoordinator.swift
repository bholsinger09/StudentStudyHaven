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

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProvider {
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
                let email = appleIDCredential.email ?? ""
                let userID = appleIDCredential.user
                let emailToUse = !email.isEmpty ? email : "\(userID)@appleid.local"
                let credentials = LoginCredentials(email: emailToUse, password: userID)
                let session = try await authRepository.login(credentials: credentials)
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
            switch asError.code {
            case .canceled:
                appError = AppError.authenticationFailed("Sign in with Apple was cancelled")
            case .failed:
                appError = AppError.authenticationFailed("Sign in with Apple failed")
            case .invalidResponse:
                appError = AppError.authenticationFailed("Invalid response from Apple")
            case .notHandled:
                appError = AppError.authenticationFailed("Sign in request not handled")
            case .unknown:
                appError = AppError.authenticationFailed("Unknown error occurred")
            @unknown default:
                appError = AppError.authenticationFailed("Unknown error occurred")
            }
        } else {
            appError = error
        }
        continuation?.resume(throwing: appError)
    }

    @objc
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow })
        else {
            fatalError("No key window found")
        }
        return window
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
