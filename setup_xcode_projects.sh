#!/bin/bash
set -e

# Use script directory as project root (works anywhere)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create iOS app bundle
create_ios_app() {
    echo "📱 Setting up iOS app project..."
    
    # Create project directories
    mkdir -p "$ROOT_DIR/StudentStudyHaven-iOS/StudentStudyHaven/Base.lproj"
    mkdir -p "$ROOT_DIR/StudentStudyHaven-iOS/StudentStudyHaven/Assets.xcassets/AppIcon.appiconset"
    
    # Copy app source files
    cp -r "$ROOT_DIR/Sources/App/"* "$ROOT_DIR/StudentStudyHaven-iOS/StudentStudyHaven/" 2>/dev/null || true
    
    # Create LaunchScreen.storyboard
    cat > "$ROOT_DIR/StudentStudyHaven-iOS/StudentStudyHaven/Base.lproj/LaunchScreen.storyboard" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="21507" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreaLayoutGuide="YES" colorGamutSupported="YES">
    <device id="retina6_1" orientation="portrait" appearance="light"/>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="21505"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <scene sceneID="lse-lT-fRe">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="414" height="896"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="StudentStudyHaven" textAlignment="center" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="GJd-yL-e9t">
                                <rect key="frame" x="0.0" y="403" width="414" height="90"/>
                                <fontDescription key="fontDescription" type="system" pointSize="45"/>
                                <nil key="textColor"/>
                                <nil key="highlightedColor"/>
                            </label>
                        </subviews>
                        <viewLayoutGuide key="safeArea" id="Bcu-3y-fBC"/>
                        <constraints>
                            <constraint firstItem="GJd-yL-e9t" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1Xw-rQ-2kI"/>
                            <constraint firstItem="GJd-yL-e9t" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4ua-4v-Lqb"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
</document>
EOF
    
    # Create Info.plist for iOS
    cat > "$ROOT_DIR/StudentStudyHaven-iOS/StudentStudyHaven/Info.plist" << 'EOF'
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
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF
    
    echo "✅ iOS app setup complete"
}

# Function to create macOS app bundle
create_macos_app() {
    echo "🍎 Setting up macOS app project..."
    
    # Create project directory
    mkdir -p "$ROOT_DIR/StudentStudyHaven-macOS/StudentStudyHaven"
    mkdir -p "$ROOT_DIR/StudentStudyHaven-macOS/StudentStudyHaven/Assets.xcassets/AppIcon.appiconset"
    
    # Copy app source files
    cp -r "$ROOT_DIR/Sources/App/"* "$ROOT_DIR/StudentStudyHaven-macOS/StudentStudyHaven/" 2>/dev/null || true
    
    # Create Info.plist for macOS
    cat > "$ROOT_DIR/StudentStudyHaven-macOS/StudentStudyHaven/Info.plist" << 'EOF'
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
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSMainStoryboardFile</key>
    <string>Main</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF
    
    echo "✅ macOS app setup complete"
}

# Create both apps
create_ios_app
create_macos_app

echo "🎉 All app structures created successfully!"
