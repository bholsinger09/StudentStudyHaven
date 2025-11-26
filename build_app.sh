#!/bin/bash

# Build script for StudentStudyHaven macOS app
set -e

echo "🏗️  Building StudentStudyHaven..."

# Clean previous builds
rm -rf .build/app

# Build the Swift package
swift build -c release

# Get the built executable path
EXECUTABLE_PATH=".build/release/StudentStudyHaven"

if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "❌ Build failed - executable not found at $EXECUTABLE_PATH"
    exit 1
fi

echo "✅ Build successful"
echo "📦 Creating app bundle..."

# Create app bundle structure
APP_BUNDLE=".build/app/StudentStudyHaven.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp "$EXECUTABLE_PATH" "$MACOS/StudentStudyHaven"
chmod +x "$MACOS/StudentStudyHaven"

# Copy Info.plist
cp "Info.plist" "$CONTENTS/Info.plist"

# Create PkgInfo file
echo "APPL????" > "$CONTENTS/PkgInfo"

echo "✅ App bundle created at $APP_BUNDLE"
echo ""
echo "🚀 To run the app:"
echo "   open $APP_BUNDLE"
echo ""
echo "Or run directly:"
echo "   $MACOS/StudentStudyHaven"
