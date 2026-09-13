# 🚀 StudentStudyHaven Deployment Guide

## Current Status: ✅ Ready for Deployment

Your project is clean, compiles successfully, and is ready for iOS and macOS deployment to the App Store.

---

## Quick Start

### Prerequisites
- Xcode 16.4.1 or later
- Swift 6.3.1 or later
- Valid Apple Developer Account
- Signing certificates and provisioning profiles

### 30-Second Build Test
```bash
cd /Users/benh/Documents/StudentStudyHaven
./build.sh build-package
```

Expected output: `✅ Package built successfully`

---

## Build Commands

### Using Build Script (Recommended)
```bash
# Build debug version
./build.sh build-package

# Build release version
./build.sh build-package Release

# Run unit tests
./build.sh test

# Build for iOS simulator
./build.sh build-ios-sim

# Build for iOS device
./build.sh build-ios-device

# Build for macOS
./build.sh build-macos

# Clean build artifacts
./build.sh clean

# Show project info
./build.sh info
```

### Direct Swift Package Commands
```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests
swift test

# Run specific test
swift test --filter CoreTests
```

---

## iOS Deployment Path

### Step 1: Build for iOS Device
```bash
./build.sh build-ios-device
```

### Step 2: Archive for App Store
```bash
./build.sh archive-ios
```

### Step 3: Sign & Upload
1. Open Xcode: `open StudentStudyHaven.xcworkspace`
2. Select StudentStudyHaven-iOS scheme
3. Set team ID and signing certificate in Target Settings
4. Product → Archive
5. Distribute App → App Store Connect

### Alternative: Command Line Upload
```bash
# Requires App Store Connect credentials
xcrun altool --validate-app -f build/StudentStudyHaven-iOS.xcarchive \
    -t ios \
    -u your-apple-id@example.com \
    -p your-app-specific-password
```

---

## macOS Deployment Path

### Step 1: Build for macOS
```bash
./build.sh build-macos
```

### Step 2: Archive for Mac App Store
```bash
./build.sh archive-macos
```

### Step 3: Sign & Upload
1. Open Xcode: `open StudentStudyHaven.xcworkspace`
2. Select StudentStudyHaven-macOS scheme
3. Set team ID and signing certificate in Target Settings
4. Product → Archive
5. Distribute App → Mac App Store

---

## Project Structure

```
StudentStudyHaven/
├── Package.swift                    ← Source of truth for all modules
├── Sources/
│   ├── App/                         ← Main application (Views, State)
│   ├── Core/                        ← Shared utilities and models
│   ├── Authentication/              ← Auth logic
│   ├── ClassManagement/             ← Class features
│   ├── Flashcards/                  ← Flashcard features
│   ├── Notes/                       ← Note-taking features
│   └── StudyGroups/                 ← Study groups features
├── Tests/                           ← Unit tests for all modules
├── StudentStudyHaven-iOS/           ← iOS entry point
│   └── StudentStudyHaven/
│       ├── StudentStudyHavenApp.swift
│       ├── Assets.xcassets/
│       ├── LaunchScreen.storyboard
│       └── Info.plist
├── StudentStudyHaven-macOS/         ← macOS entry point
│   └── StudentStudyHaven/
│       ├── macOSApp.swift
│       ├── Assets.xcassets/
│       └── Info.plist
├── StudentStudyHaven.xcworkspace/   ← Coordinates everything
├── build.sh                         ← Build automation script
└── BUILD_GUIDE.md                   ← Detailed build documentation
```

---

## Configuration Checklist

### Before Deploying to App Store

- [ ] **Bundle Identifiers**
  - iOS: `com.studentstudyhaven.ios`
  - macOS: `com.studentstudyhaven.macos`
  - Change in respective `Info.plist` files

- [ ] **Code Signing**
  - [ ] Valid development team selected in Xcode
  - [ ] Provisioning profiles installed
  - [ ] Signing certificates valid and not expired

- [ ] **App Icon**
  - [ ] Create app icon (1024x1024 minimum)
  - [ ] Add to `Assets.xcassets/AppIcon.appiconset`

- [ ] **Launch Screen**
  - [ ] Customize `LaunchScreen.storyboard` if desired
  - [ ] Or configure launch screen in `Info.plist`

- [ ] **App Name & Metadata**
  - [ ] Update app name in `Info.plist` files
  - [ ] Verify CFBundleName matches desired app name
  - [ ] Set marketing version and build number

- [ ] **Capabilities**
  - [ ] Enable required capabilities in Xcode
  - [ ] Add privacy descriptions in `Info.plist`

- [ ] **Testing**
  - [ ] Test on simulator: `./build.sh build-ios-sim`
  - [ ] Test on device
  - [ ] Run all unit tests: `./build.sh test`

---

## Versioning

Update version numbers in both `Info.plist` files and `Package.swift`:

```bash
# iOS
StudentStudyHaven-iOS/StudentStudyHaven/Info.plist
  CFBundleShortVersionString: 1.0.0
  CFBundleVersion: 1

# macOS
StudentStudyHaven-macOS/StudentStudyHaven/Info.plist
  CFBundleShortVersionString: 1.0.0
  CFBundleVersion: 1
```

---

## Troubleshooting

### Build Fails with "Module not found"
```bash
./build.sh clean
./build.sh build-package
```

### Xcode Won't Load Workspace
```bash
rm -rf StudentStudyHaven.xcworkspace
rm -rf ~/Library/Developer/Xcode/DerivedData/StudentStudyHaven*
swift package generate-xcodeproj
```

### Code Signing Issues
1. Open Xcode
2. Select each target (StudentStudyHaven-iOS, StudentStudyHaven-macOS)
3. General tab → Team ID selection
4. Signing & Capabilities → Set provisioning profile

### Framework Linking Issues
```bash
./build.sh clean
swift build
```

---

## Testing Before Release

### Unit Tests
```bash
./build.sh test
```

### Manual Testing Checklist
- [ ] App launches without crashes
- [ ] Authentication flow works
- [ ] All tabs load correctly
- [ ] Notes creation and editing works
- [ ] Class management functions properly
- [ ] Flashcards load and display
- [ ] Study groups display correctly
- [ ] Settings page functional

### Performance Testing
```bash
# Profile app performance
instruments -t "System Trace" .build/debug/StudentStudyHaven
```

---

## App Store Submission

### iOS
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new iOS app
3. Fill in app information:
   - Name, description, keywords
   - Screenshots (2-5 per device size)
   - Privacy policy
   - Support URL
4. Set pricing and availability
5. Upload build via Xcode or Transporter
6. Submit for review

### macOS
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new macOS app
3. Fill in app information (similar to iOS)
4. Set technical specifications:
   - Category
   - Content rating
   - Privacy manifest
5. Upload build and submit for review

---

## Release Notes

Keep track of changes between releases:

```markdown
### Version 1.0.0 (Initial Release)
- Authentication with Sign in with Apple
- Class management and scheduling
- Note-taking in classroom
- Flashcard study tools
- Study group collaboration
- Cross-platform support (iOS 16+, macOS 13+)
```

---

## Monitoring Post-Release

### App Analytics
- Monitor daily active users
- Track crash reports in Xcode
- Review user feedback and ratings
- Monitor performance metrics

### Updates
```bash
# For bug fixes or minor updates
./build.sh build-package Release
./build.sh archive-ios
# Submit new version to App Store Connect
```

---

## Support & Resources

- **Apple Developer Documentation**: https://developer.apple.com
- **App Store Connect Help**: https://help.apple.com/app-store-connect
- **Swift Package Manager**: https://swift.org/package-manager
- **Xcode Help**: `Help → Xcode Help` in Xcode

---

## Key Files to Review Before Release

1. **Package.swift** - Dependency declarations and target configuration
2. **Sources/App/StudentStudyHavenApp.swift** - Main app entry point
3. **StudentStudyHaven-iOS/StudentStudyHaven/Info.plist** - iOS configuration
4. **StudentStudyHaven-macOS/StudentStudyHaven/Info.plist** - macOS configuration
5. **BUILD_GUIDE.md** - Detailed build instructions

---

**Last Updated**: September 12, 2026  
**Status**: ✅ Ready for Production Release  
**Swift Version**: 6.3.1  
**Xcode Version**: 26.4.1  
**iOS Minimum**: iOS 16.0  
**macOS Minimum**: macOS 13.0
