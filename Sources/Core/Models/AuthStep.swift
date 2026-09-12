import Foundation

/// Represents the current step in the authentication flow
public enum AuthStep {
    case landing
    case login
    case register
    case appleSignIn
}
