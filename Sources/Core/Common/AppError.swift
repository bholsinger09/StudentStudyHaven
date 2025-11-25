import Foundation

/// Common error types used throughout the application
public enum AppError: Error, LocalizedError, Equatable {
    case networkError(String)
    case authenticationFailed(String)
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case invalidData(String)
    case notFound(String)
    case unauthorized
    case serverError(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .invalidData(let message):
            return "Invalid Data: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}
