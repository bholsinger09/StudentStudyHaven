#!/bin/bash
set -e

PROJECT_DIR="StudentStudyHaven"

echo "================================================"
echo "CONFIGURING iOS PROJECT"
echo "================================================"
echo ""

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Error: $PROJECT_DIR not found!"
    echo "Please create the iOS project first using create_ios_instructions.sh"
    exit 1
fi

cd "$PROJECT_DIR"

echo "1. Removing default ContentView.swift..."
rm -f StudentStudyHaven/ContentView.swift 2>/dev/null || true

echo "2. Copying all app source files..."
cp -f ../StudentStudyHaven/StudentStudyHaven/*.swift StudentStudyHaven/ 2>/dev/null || true

echo "3. Copying entitlements..."
cp -f ../StudentStudyHaven/StudentStudyHaven/*.entitlements StudentStudyHaven/ 2>/dev/null || true

echo "4. Copying Assets..."
rm -rf StudentStudyHaven/Assets.xcassets
cp -r ../StudentStudyHaven/StudentStudyHaven/Assets.xcassets StudentStudyHaven/ 2>/dev/null || true

cd ..

echo ""
echo "✅ Project configured!"
echo ""
echo "================================================"
echo "FINAL STEPS IN XCODE:"
echo "================================================"
echo ""
echo "1. Open the project:"
echo "   open StudentStudyHaven/StudentStudyHaven.xcodeproj"
echo ""
echo "2. In Xcode project navigator:"
echo "   - Right-click on 'StudentStudyHaven' folder"
echo "   - Select 'Add Package Dependencies...'"
echo "   - Click 'Add Local...'"
echo "   - Navigate to: /Users/benh/Documents/StudentStudyHaven/"
echo "   - Select 'Package.swift'"
echo "   - Click 'Add Package'"
echo ""
echo "3. Select all the package products:"
echo "   ☑️ App"
echo "   ☑️ Authentication  "
echo "   ☑️ ClassManagement"
echo "   ☑️ Core"
echo "   ☑️ Flashcards"
echo "   ☑️ Notes"
echo "   ☑️ StudyGroups"
echo ""
echo "4. Click 'Add Package'"
echo ""
echo "5. In project settings:"
echo "   - Select 'Student Study Haven' target"
echo "   - Go to 'Signing & Capabilities' tab"
echo "   - Check 'Automatically manage signing'"
echo "   - Select your Team"
echo ""
echo "6. Select your iPhone as destination"
echo ""
echo "7. Press Cmd+R to build and run!"
echo ""
echo "The app will now have all our changes including the Add Member button!"
echo ""
