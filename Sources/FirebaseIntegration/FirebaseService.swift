import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Central Firebase service for app-wide initialization and configuration
public class FirebaseService {
    public static let shared = FirebaseService()
    
    private var isInitialized = false
    
    public var auth: Auth {
        return Auth.auth()
    }
    
    public var firestore: Firestore {
        return Firestore.firestore()
    }
    
    /// Initialize Firebase with app-wide configuration
    /// Call this once during app launch
    public func initialize() {
        guard !isInitialized else { return }
        
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        
        isInitialized = true
    }
    
    /// Get current authenticated user
    public var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
}
