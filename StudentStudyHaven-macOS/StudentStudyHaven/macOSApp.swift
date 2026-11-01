import SwiftUI
import App
import FirebaseCore

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}
#endif

@main
struct macOSApp: App {
    @StateObject private var appState = AppState()
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif

    init() {
        // Enable Firebase repositories for real data persistence
        DependencyContainer.shared.useMockRepositories = false
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onAppear {
                    #if os(macOS)
                    NSApp?.activate(ignoringOtherApps: true)
                    #endif
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
