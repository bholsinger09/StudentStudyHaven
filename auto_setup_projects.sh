#!/bin/bash

# Auto-create Xcode iOS and macOS projects
# This script creates deployable app projects automatically

set -e

cd "$(dirname "$0")"

echo "🎯 Auto-generating iOS and macOS app projects..."
echo ""

# Create iOS project structure
echo "📱 Creating iOS App Project..."
mkdir -p "StudentStudyHaven-iOS/StudentStudyHaven-iOS"
mkdir -p "StudentStudyHaven-iOS/StudentStudyHaven-iOS/Preview Content"
mkdir -p "StudentStudyHaven-iOS/StudentStudyHaven-iOS.xcodeproj"

# iOS App Entry Point
cat > "StudentStudyHaven-iOS/StudentStudyHaven-iOS/StudentStudyHaven_iOSApp.swift" << 'EOF'
import SwiftUI
import Core
import Authentication
import ClassManagement
import Flashcards
import Notes

@main
struct StudentStudyHaven_iOSApp: App {
    @StateObject private var appState = AppState.shared

    init() {
        // Use mock repositories for testing
        DependencyContainer.shared.useMockRepositories = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
EOF

# Copy RootView and all views
cp -r "App/RootView.swift" "StudentStudyHaven-iOS/StudentStudyHaven-iOS/" 2>/dev/null || echo "Copying views..."
cp -r "App/Views" "StudentStudyHaven-iOS/StudentStudyHaven-iOS/" 2>/dev/null || true
cp -r "Sources/App/"*.swift "StudentStudyHaven-iOS/StudentStudyHaven-iOS/" 2>/dev/null || true

# iOS Info.plist
cat > "StudentStudyHaven-iOS/StudentStudyHaven-iOS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>Student Study Haven</string>
	<key>CFBundleIdentifier</key>
	<string>com.studentstudyhaven.app</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<true/>
	</dict>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.education</string>
</dict>
</plist>
EOF

# Create macOS project structure
echo "💻 Creating macOS App Project..."
mkdir -p "StudentStudyHaven-macOS/StudentStudyHaven-macOS"
mkdir -p "StudentStudyHaven-macOS/StudentStudyHaven-macOS/Preview Content"
mkdir -p "StudentStudyHaven-macOS/StudentStudyHaven-macOS.xcodeproj"

# macOS App Entry Point
cat > "StudentStudyHaven-macOS/StudentStudyHaven-macOS/StudentStudyHaven_macOSApp.swift" << 'EOF'
import SwiftUI
import Core
import Authentication
import ClassManagement
import Flashcards
import Notes

@main
struct StudentStudyHaven_macOSApp: App {
    @StateObject private var appState = AppState.shared

    init() {
        // Use mock repositories for testing
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
EOF

# Copy views to macOS
cp -r "App/RootView.swift" "StudentStudyHaven-macOS/StudentStudyHaven-macOS/" 2>/dev/null || true
cp -r "App/Views" "StudentStudyHaven-macOS/StudentStudyHaven-macOS/" 2>/dev/null || true
cp -r "Sources/App/"*.swift "StudentStudyHaven-macOS/StudentStudyHaven-macOS/" 2>/dev/null || true

# macOS Info.plist  
cp "Info.plist" "StudentStudyHaven-macOS/StudentStudyHaven-macOS/Info.plist"

echo ""
echo "✅ Project structures created!"
echo ""
echo "📝 NOW IN XCODE:"
echo ""
echo "1. Open Xcode"
echo "2. File > Open > Select StudentStudyHaven.xcworkspace"
echo "3. For EACH project (iOS and macOS):"
echo "   a. Click the project in sidebar"
echo "   b. General tab > Identity section"
echo "   c. Set your Team"
echo "   d. Frameworks, Libraries & Embedded Content section"
echo "   e. Click + > Add Other > Add Local Package"
echo "   f. Select Package.swift from main folder"
echo "   g. Check: Core, Authentication, ClassManagement, Flashcards, Notes"
echo ""
echo "4. Build and Archive!"
echo ""
echo "Opening workspace..."
open StudentStudyHaven.xcworkspace 2>/dev/null || echo "Please open StudentStudyHaven.xcworkspace manually"
