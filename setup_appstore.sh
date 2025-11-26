#!/bin/bash

# StudentStudyHaven - App Store Deployment Setup Script
# This script creates proper Xcode app targets for iOS and macOS deployment

set -e

echo "🚀 Setting up StudentStudyHaven for App Store deployment..."
echo ""

PROJECT_DIR="/Users/benh/Documents/StudentStudyHaven"
cd "$PROJECT_DIR"

# Create app directories
echo "📁 Creating app structure..."
mkdir -p "Apps/iOS"
mkdir -p "Apps/macOS"

# Create iOS App files
echo "📱 Setting up iOS App..."

# iOS Info.plist
cat > "Apps/iOS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>Student Study Haven</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>com.studentstudyhaven.app</string>
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
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<true/>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.education</string>
</dict>
</plist>
EOF

# Create macOS App files
echo "💻 Setting up macOS App..."

# macOS Info.plist (already exists at root, copy it)
cp "Info.plist" "Apps/macOS/Info.plist"

# Create main app entry point files
echo "📝 Creating app entry points..."

# Copy App source to both platforms
cp -r "Sources/App/"* "Apps/iOS/" 2>/dev/null || true
cp -r "Sources/App/"* "Apps/macOS/" 2>/dev/null || true

# Create Xcode project using ruby script
echo "🔨 Generating Xcode projects..."

ruby << 'RUBY_SCRIPT'
require 'xcodeproj'

project_path = '/Users/benh/Documents/StudentStudyHaven/StudentStudyHaven.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Create iOS target
ios_target = project.new_target(:application, 'StudentStudyHaven-iOS', :ios, '16.0')
ios_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.studentstudyhaven.app'
  config.build_settings['INFOPLIST_FILE'] = 'Apps/iOS/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
end

# Create macOS target
macos_target = project.new_target(:application, 'StudentStudyHaven-macOS', :osx, '13.0')
macos_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.studentstudyhaven.mac.app'
  config.build_settings['INFOPLIST_FILE'] = 'Apps/macOS/Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.9'
end

project.save
RUBY_SCRIPT

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open StudentStudyHaven.xcodeproj in Xcode"
echo "2. Select the iOS or macOS scheme"
echo "3. Product > Archive to create builds for App Store"
echo ""
echo "Note: You'll need to:"
echo "  - Add app icons"
echo "  - Configure code signing"
echo "  - Add your Apple Developer Team"
echo ""
