#!/usr/bin/env swift
import Foundation

let rootPath = "/Users/benh/Documents/StudentStudyHaven"

// Create iOS project
print("📱 Creating iOS project...")
let iosProjectPath = "\(rootPath)/StudentStudyHaven-iOS"
try? FileManager.default.removeItem(atPath: iosProjectPath)

// Create directory structure
let iosPaths = [
    "\(iosProjectPath)/StudentStudyHaven",
    "\(iosProjectPath)/StudentStudyHaven/Assets.xcassets",
]

for path in iosPaths {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
}

// Copy app files from Sources/App
let appSourcePath = "\(rootPath)/Sources/App"
do {
    let appFiles = try FileManager.default.contentsOfDirectory(atPath: appSourcePath)
    for file in appFiles {
        let sourcePath = "\(appSourcePath)/\(file)"
        let destPath = "\(iosProjectPath)/StudentStudyHaven/\(file)"
        try? FileManager.default.removeItem(atPath: destPath)
        try FileManager.default.copyItem(atPath: sourcePath, toPath: destPath)
    }
} catch {
    print("Error copying app files: \(error)")
}

// Copy Info.plist
let infoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
</dict>
</plist>
"""

try infoPlistContent.write(toFile: "\(iosProjectPath)/StudentStudyHaven/Info.plist", atomically: true, encoding: .utf8)

print("✅ iOS project structure created at: StudentStudyHaven-iOS/")

// Create macOS project
print("🍎 Creating macOS project...")
let macProjectPath = "\(rootPath)/StudentStudyHaven-macOS"
try? FileManager.default.removeItem(atPath: macProjectPath)

let macPaths = [
    "\(macProjectPath)/StudentStudyHaven",
    "\(macProjectPath)/StudentStudyHaven/Assets.xcassets",
]

for path in macPaths {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
}

// Copy app files from Sources/App
do {
    let appFiles = try FileManager.default.contentsOfDirectory(atPath: appSourcePath)
    for file in appFiles {
        let sourcePath = "\(appSourcePath)/\(file)"
        let destPath = "\(macProjectPath)/StudentStudyHaven/\(file)"
        try? FileManager.default.removeItem(atPath: destPath)
        try FileManager.default.copyItem(atPath: sourcePath, toPath: destPath)
    }
} catch {
    print("Error copying app files: \(error)")
}

// Copy macOS Info.plist
let macInfoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSMainStoryboardFile</key>
    <string>Main</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSPrivacyTracking</key>
    <false/>
</dict>
</plist>
"""

try macInfoPlistContent.write(toFile: "\(macProjectPath)/StudentStudyHaven/Info.plist", atomically: true, encoding: .utf8)

print("✅ macOS project structure created at: StudentStudyHaven-macOS/")
