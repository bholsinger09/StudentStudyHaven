import SwiftUI
import App
import FirebaseIntegration
import os.log

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Log to console with OSLog
        let log = OSLog(subsystem: "com.bholsinger.studentstudyhaven", category: "startup")
        os_log("🚀 App launching - AppDelegate.application()", log: log, type: .info)
        
        os_log("📍 Initializing Firebase", log: log, type: .info)
        FirebaseService.shared.initialize()
        os_log("✅ Firebase initialized successfully", log: log, type: .info)
        
        return true
    }
}

@main
struct iOSApp: App {
    @StateObject private var appState = AppState()
    
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
