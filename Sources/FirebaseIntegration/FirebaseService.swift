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
        
        // Verify GoogleService-Info.plist exists
        guard let configPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            let bundleContents = (try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)) ?? []
            print("❌ ERROR: GoogleService-Info.plist not found in bundle")
            print("Bundle path: \(Bundle.main.bundlePath)")
            print("Bundle contents: \(bundleContents)")
            fatalError("GoogleService-Info.plist is missing from app bundle")
        }
        
        print("✅ Found GoogleService-Info.plist at: \(configPath)")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        
        // Configure Firestore settings with new API
        let cacheSettings = PersistentCacheSettings(sizeBytes: 100_000_000)
        let settings = FirestoreSettings()
        settings.cacheSettings = cacheSettings
        Firestore.firestore().settings = settings
        
        print("✅ Firestore persistence enabled")
        
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
