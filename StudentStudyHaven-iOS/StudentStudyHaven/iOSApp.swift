import SwiftUI
import App

@main
struct iOSApp: App {
    @StateObject private var appState = AppState()

    init() {
        DependencyContainer.shared.useMockRepositories = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
