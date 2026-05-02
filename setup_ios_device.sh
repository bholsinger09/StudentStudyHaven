#!/bin/bash
set -e

echo "=========================================="
echo "CREATING iOS APP PROJECT FOR DEVICE"
echo "=========================================="
echo ""

cd /Users/benh/Documents/StudentStudyHaven

# Create a simple iOS app using xcodegen or manual setup
# First, let's create the project with xcodebuild

PROJECT_NAME="StudentStudyHavenApp"
BUNDLE_ID="com.studentstudyhaven.app"

echo "1. Creating iOS app project: $PROJECT_NAME"

# Create directory structure
mkdir -p "$PROJECT_NAME/$PROJECT_NAME"
cd "$PROJECT_NAME"

# Copy all app files from StudentStudyHaven/StudentStudyHaven/
echo "2. Copying app source files..."
cp -r ../StudentStudyHaven/StudentStudyHaven/*.swift "$PROJECT_NAME/" 2>/dev/null || true

# Create Assets catalog
mkdir -p "$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset"

cat > "$PROJECT_NAME/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

cat > "$PROJECT_NAME/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Info.plist
cat > "$PROJECT_NAME/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
</dict>
</plist>
EOF

cd ..

echo ""
echo "3. Creating Xcode project using command line..."

# Check if we can use xcodebuild
if command -v xcodebuild &> /dev/null; then
    echo "✅ xcodebuild found"
else
    echo "❌ xcodebuild not found"
fi

echo ""
echo "=========================================="
echo "MANUAL XCODE SETUP REQUIRED"
echo "=========================================="
echo ""
echo "Automated project creation requires additional tools."
echo "Please follow these steps in Xcode:"
echo ""
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Select: iOS → App"
echo "4. Click Next"
echo "5. Fill in:"
echo "   - Product Name: StudentStudyHaven"
echo "   - Team: [Your Apple ID]"
echo "   - Organization Identifier: com.studentstudyhaven"
echo "   - Bundle Identifier: com.studentstudyhaven.app"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "6. Click Next"
echo "7. Save to: /Users/benh/Documents/StudentStudyHaven/"
echo "8. In the created project:"
echo "   - Delete ContentView.swift"
echo "   - Right-click project → Add Files"
echo "   - Add all .swift files from StudentStudyHaven/StudentStudyHaven/"
echo "   - Right-click project → Add Package Dependencies → Add Local"
echo "   - Select Package.swift from /Users/benh/Documents/StudentStudyHaven"
echo ""
echo "OR I can guide you through a simpler automated approach?"
echo ""
