#!/bin/bash
set -e

echo "📱 Creating iOS Xcode Project..."

cd /Users/benh/Documents/StudentStudyHaven

# Create iOS project directory structure
mkdir -p IOS_Student_Haven/IOS_Student_Haven

# Copy app files
cp -r StudentStudyHaven/StudentStudyHaven/* IOS_Student_Haven/IOS_Student_Haven/

# Create Info.plist
cat > IOS_Student_Haven/IOS_Student_Haven/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
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
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF

echo "✅ iOS app structure created at: IOS_Student_Haven/"
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode"
echo "2. File → New → Project → iOS → App"
echo "3. Product Name: IOS_Student_Haven"
echo "4. Save location: /Users/benh/Documents/StudentStudyHaven/"
echo "5. Replace the created files with: IOS_Student_Haven/IOS_Student_Haven/"
echo "6. Add Package Dependencies (local): Point to Package.swift"
echo ""
echo "Or simply run: open -a Xcode IOS_Student_Haven"
