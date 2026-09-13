import SwiftUI
import App

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
                    NSApp?.activate(ignoringOtherApps: true)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
