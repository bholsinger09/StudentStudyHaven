import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import SwiftUI

public struct StudentStudyHavenApp: App {
    @StateObject private var appState = AppState()

    public init() {
        // Use real CloudKit repositories for device testing
        // Set to true only for testing without iCloud
        DependencyContainer.shared.useMockRepositories = false
    }

    public var body: some Scene {
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
