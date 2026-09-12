import SwiftUI

@main
struct iOSAppEntry: App {
    var body: some Scene {
        WindowGroup {
            // Import the App module's StudentStudyHavenApp
            // by using the framework's public entry point directly
            ContentView()
        }
    }
}

// Workaround: Define a minimal app structure that matches StudentStudyHavenApp
// This will be replaced by properly importing once module resolution is fixed
struct ContentView: View {
    var body: some View {
        Text("Loading App...")
    }
}
