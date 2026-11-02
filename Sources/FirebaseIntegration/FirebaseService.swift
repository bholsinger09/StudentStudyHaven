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
        
        do {
            // Verify GoogleService-Info.plist exists
            guard let configPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
                print("❌ ERROR: GoogleService-Info.plist not found in bundle")
                print("Bundle path: \(Bundle.main.bundlePath)")
                print("Bundle contents: \(try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) ?? [])")
                fatalError("GoogleService-Info.plist is missing from app bundle")
            }
            
            print("✅ Found GoogleService-Info.plist at: \(configPath)")
            
            // Attempt Firebase configuration
            do {
                FirebaseApp.configure()
                print("✅ Firebase configured successfully")
            } catch {
                print("❌ Firebase configuration failed: \(error)")
                throw error
            }
            
            // Configure Firestore settings
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = true
            Firestore.firestore().settings = settings
            
            print("✅ Firestore persistence enabled")
            
            isInitialized = true
        } catch {
            print("❌ Fatal error during Firebase initialization: \(error)")
            fatalError("Firebase initialization failed: \(error)")
        }
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
