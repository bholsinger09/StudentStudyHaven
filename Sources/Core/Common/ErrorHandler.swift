import Core
import Foundation

/// Centralized error handling utility
public class ErrorHandler {
    
    /// Convert an error to a user-friendly message
    public static func userFriendlyMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return userFriendlyMessage(for: appError)
        }
        
        // Handle network errors
        if let urlError = error as? URLError {
            return networkErrorMessage(for: urlError)
        }
        
        // Default message
        return "An unexpected error occurred. Please try again."
    }
    
    /// Convert AppError to user-friendly message
    private static func userFriendlyMessage(for error: AppError) -> String {
        switch error {
        case .networkError(let message):
            return message.isEmpty ? "Network connection error. Please check your internet connection." : message
            
        case .invalidData(let message):
            return message
            
        case .unauthorized:
            return "Your session has expired. Please log in again."
            
        case .notFound:
            return "The requested item could not be found."
            
        case .serverError(let message):
            return "Server error: \(message)"
            
        case .authenticationFailed(let message):
            return message
            
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
            
        case .userNotFound:
            return "No account found with this email address."
            
        case .emailAlreadyExists:
            return "An account with this email already exists."
            
        case .unknown(let message):
            return message.isEmpty ? "An unexpected error occurred." : message
        }
    }
    
    /// Convert URLError to user-friendly message
    private static func networkErrorMessage(for error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "No internet connection. Please check your network settings."
            
        case .timedOut:
            return "The request timed out. Please try again."
            
        case .cannotFindHost, .cannotConnectToHost:
            return "Cannot connect to server. Please try again later."
            
        case .networkConnectionLost:
            return "Network connection was lost. Please try again."
            
        case .badServerResponse:
            return "Invalid response from server. Please try again."
            
        default:
            return "Network error occurred. Please check your connection."
        }
    }
    
    /// Determine if an error is retryable
    public static func isRetryable(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        
        if let appError = error as? AppError {
            switch appError {
            case .networkError, .serverError:
                return true
            default:
                return false
            }
        }
        
        return false
    }
    
    /// Log error for analytics/debugging
    public static func log(_ error: Error, context: String = "") {
        #if DEBUG
        print("❌ Error in \(context): \(error.localizedDescription)")
        #endif
        
        // In production, send to analytics service
        // Analytics.logError(error, context: context)
    }
}

/// Retry configuration
public struct RetryConfig {
    public let maxAttempts: Int
    public let delaySeconds: Double
    public let exponentialBackoff: Bool
    
    public init(maxAttempts: Int = 3, delaySeconds: Double = 1.0, exponentialBackoff: Bool = true) {
        self.maxAttempts = maxAttempts
        self.delaySeconds = delaySeconds
        self.exponentialBackoff = exponentialBackoff
    }
    
    public static let `default` = RetryConfig()
}

/// Retry mechanism for async operations
public func withRetry<T>(
    config: RetryConfig = .default,
    operation: @escaping () async throws -> T
) async throws -> T {
    var lastError: Error?
    
    for attempt in 1...config.maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            
            // Don't retry if not retryable or last attempt
            guard ErrorHandler.isRetryable(error), attempt < config.maxAttempts else {
                throw error
            }
            
            // Calculate delay with optional exponential backoff
            let delay = config.exponentialBackoff
                ? config.delaySeconds * pow(2.0, Double(attempt - 1))
                : config.delaySeconds
            
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    
    throw lastError ?? AppError.unknown("Retry failed")
}
