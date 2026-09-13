import SwiftUI
import App

#if os(macOS)
import AppKit
#endif

@main
struct macOSApp: App {
    @StateObject private var appState = AppState()

    init() {
        DependencyContainer.shared.useMockRepositories = true
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
