import Foundation
// Firebase temporarily disabled
// import FirebaseCore
// import FirebaseAuth
// import FirebaseFirestore

/// Firebase configuration and initialization manager
/// TEMPORARILY DISABLED - Using mock repositories
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
        
        // Firebase temporarily disabled
        print("⚠️ Firebase disabled - using mock repositories")
        isConfigured = true
        
        // FirebaseApp.configure()
        // 
        // // Enable offline persistence for Firestore
        // let settings = FirestoreSettings()
        // settings.isPersistenceEnabled = true
        // settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        // Firestore.firestore().settings = settings
        // 
        // isConfigured = true
        // print("✅ Firebase configured successfully")
    }
    
    /// Get the current authenticated user ID
    public var currentUserId: String? {
        // Firebase temporarily disabled
        return nil
        // Auth.auth().currentUser?.uid
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        // Firebase temporarily disabled
        return false
        // Auth.auth().currentUser != nil
    }
    
    // Firebase temporarily disabled
    // /// Get Firestore reference
    // public var firestore: Firestore {
    //     Firestore.firestore()
    // }
    // 
    // /// Get Auth reference
    // public var auth: Auth {
    //     Auth.auth()
    // }
}
