import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Firebase configuration and initialization manager
/// Configured to explicitly disable analytics and TrueDepth-related APIs
@MainActor
public class FirebaseManager {
    public static let shared = FirebaseManager()
    
    private var isConfigured = false
    
    private init() {}
    
    /// Configure Firebase with the app
    /// This should be called once at app startup
    public func configure() {
        guard !isConfigured else {
            print("⚠️ Firebase already configured")
            return
        }
        
        // Configure Firebase with analytics explicitly disabled
        FirebaseApp.configure()
        
        // IMPORTANT: Explicitly disable analytics to avoid TrueDepth API references
        // This prevents Firebase from including device capability detection
        #if canImport(FirebaseAnalytics)
        import FirebaseAnalytics
        Analytics.setAnalyticsCollectionEnabled(false)
        #endif
        
        // Enable offline persistence for Firestore
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        isConfigured = true
        print("✅ Firebase configured successfully (Analytics disabled)")
    }
    
    /// Get the current authenticated user ID
    public var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
    
    /// Get Firestore reference
    public var firestore: Firestore {
        Firestore.firestore()
    }
    
    /// Get Auth reference
    public var auth: Auth {
        Auth.auth()
    }
}
