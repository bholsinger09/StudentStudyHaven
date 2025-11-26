#!/bin/bash

# StudentStudyHaven - Create deployable Xcode workspace
# This creates a proper workspace structure for App Store deployment

set -e

echo "🚀 Creating deployable Xcode workspace for StudentStudyHaven..."
echo ""

PROJECT_DIR="$(pwd)"

# Step 1: Create workspace
echo "📦 Creating Xcode workspace..."
mkdir -p StudentStudyHaven.xcworkspace
cat > StudentStudyHaven.xcworkspace/contents.xcworkspacedata << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:StudentStudyHaven-iOS/StudentStudyHaven-iOS.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:StudentStudyHaven-macOS/StudentStudyHaven-macOS.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:Package.swift">
   </FileRef>
</Workspace>
EOF

echo "✅ Workspace created"
echo ""
echo "📋 MANUAL STEPS REQUIRED:"
echo ""
echo "Since Xcode projects must be created through Xcode GUI for proper configuration,"
echo "please follow these steps:"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "FOR iOS APP:"
echo "════════════════════════════════════════════════════════════════"
echo "1. Open Xcode"
echo "2. File > New > Project"
echo "3. Choose: iOS > App"
echo "4. Product Name: StudentStudyHaven-iOS"
echo "5. Team: Select your Apple Developer team"
echo "6. Organization Identifier: com.studentstudyhaven"
echo "7. Bundle Identifier: com.studentstudyhaven.app"
echo "8. Interface: SwiftUI"
echo "9. Language: Swift"
echo "10. Save in: $PROJECT_DIR/StudentStudyHaven-iOS"
echo ""
echo "Then in the project:"
echo "  a) Delete the default ContentView.swift and App file"
echo "  b) Right-click project > Add Package Dependencies"
echo "  c) Add Local > Select your Package.swift"
echo "  d) In your main app file, import and use your modules"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "FOR macOS APP:"
echo "════════════════════════════════════════════════════════════════"
echo "1. File > New > Project"
echo "2. Choose: macOS > App"
echo "3. Product Name: StudentStudyHaven-macOS"
echo "4. Team: Select your Apple Developer team"
echo "5. Organization Identifier: com.studentstudyhaven"
echo "6. Bundle Identifier: com.studentstudyhaven.mac.app"
echo "7. Interface: SwiftUI"
echo "8. Language: Swift"
echo "9. Save in: $PROJECT_DIR/StudentStudyHaven-macOS"
echo ""
echo "Then in the project:"
echo "  a) Delete the default ContentView.swift and App file"
echo "  b) Right-click project > Add Package Dependencies"
echo "  c) Add Local > Select your Package.swift"
echo "  d) In your main app file, import and use your modules"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "ALTERNATIVE: Use the automated script below"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Create a helper script that users can follow
cat > DEPLOYMENT_GUIDE.md << 'EOF'
# App Store Deployment Guide

## Current Status
Your project is a Swift Package which cannot be directly archived for App Store.

## Solution Overview
We need to create separate Xcode App projects for iOS and macOS that use your Swift Package modules.

## Quick Start (Recommended)

### Option 1: Manual Creation (Most Reliable)
Follow the steps printed by the setup script to create iOS and macOS app projects in Xcode.

### Option 2: Copy Existing Code Structure
I can help you restructure the project to be an Xcode project instead of a Swift Package.

## What You'll Get
- ✅ Archivable iOS app
- ✅ Archivable macOS app  
- ✅ Shared codebase via Swift Package
- ✅ Separate bundle IDs for each platform
- ✅ Ready for TestFlight and App Store submission

## Required for App Store
- [ ] App Icons (1024x1024 for App Store, plus all sizes)
- [ ] Launch Screen
- [ ] Privacy Policy URL
- [ ] App Description and Screenshots
- [ ] Apple Developer Account ($99/year)
- [ ] Code Signing Certificates
- [ ] Provisioning Profiles

## Next Steps
1. Create the Xcode projects as described above
2. Test archiving: Product > Archive
3. Add app icons in Assets.xcassets
4. Configure code signing in project settings
5. Archive and upload to App Store Connect

Need help with any step? Let me know!
EOF

echo "📖 Created DEPLOYMENT_GUIDE.md with detailed instructions"
echo ""
echo "Would you like me to create a complete iOS/macOS app structure automatically?"
echo "This will restructure your project but preserve all your code."
echo ""
