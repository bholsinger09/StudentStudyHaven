#!/bin/bash

echo "🔥 AGGRESSIVE XCODE RESET"
echo "========================="
echo ""
echo "This will COMPLETELY wipe Xcode caches and rebuild from scratch"
echo ""
read -p "Close Xcode now (Cmd+Q) and press Enter when ready..."

# Kill any lingering Xcode processes
killall Xcode 2>/dev/null
sleep 2

echo ""
echo "⏳ Step 1: Removing ALL Xcode caches..."
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/IndexStores
rm -rf ~/Library/Developer/Xcode/Previews

echo "✅ Cleared Xcode caches"

echo ""
echo "⏳ Step 2: Removing ALL SPM caches..."
rm -rf ~/.swiftpm
rm -rf ~/.cache/swift-package-manager

echo "✅ Cleared SPM caches"

echo ""
echo "⏳ Step 3: Removing Package.resolved files..."
cd "$(dirname "$0")"
find . -name "Package.resolved" -delete

echo "✅ Removed Package.resolved"

echo ""
echo "⏳ Step 4: Removing .xcworkspace/xcuserdata..."
rm -rf StudentStudyHaven-iOS/StudentStudyHaven.xcworkspace/xcuserdata

echo "✅ Cleaned workspace user data"

echo ""
echo "✅ AGGRESSIVE RESET COMPLETE!"
echo ""
echo "Next steps:"
echo "1. Open Finder and navigate to:"
echo "   /Users/benh/Documents/StudentStudyHaven/StudentStudyHaven-iOS/"
echo "2. Delete the entire 'StudentStudyHaven.xcworkspace' folder"
echo "3. Open 'StudentStudyHaven.xcodeproj' directly (NOT the workspace)"
echo "4. Let Xcode index (2-5 minutes)"
echo "5. Try Cmd+B to build"
echo ""
