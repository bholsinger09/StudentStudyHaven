import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import SwiftUI

@main
struct StudentStudyHavenApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Configure Firebase on app launch
        // Firebase temporarily disabled - using mock repositories
        // Task { @MainActor in
        //     FirebaseManager.shared.configure()
        // }

        // Use mock repositories for now
        DependencyContainer.shared.useMockRepositories = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onAppear {
                    #if os(macOS)
                    // Prevent system from intercepting text input on macOS
                    NSApp?.activate(ignoringOtherApps: true)
                    #endif
                }
        }
        #if os(macOS)
        .commands {
            // Remove conflicting commands that might interfere with text input
            CommandGroup(replacing: .newItem) {}
        }
        #endif
    }
}
