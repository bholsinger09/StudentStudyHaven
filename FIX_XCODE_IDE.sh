#!/bin/bash

echo "🧹 XCODE IDE CACHE RESET SCRIPT"
echo "==============================="
echo ""
echo "This script will:"
echo "1. Clear Xcode DerivedData"
echo "2. Clear Xcode caches"
echo "3. Clear SPM caches"
echo "4. Remove Package.resolved files"
echo ""
echo "After running this script:"
echo "1. Close Xcode completely (Cmd+Q)"
echo "2. Run this script"
echo "3. Reopen Xcode"
echo "4. Wait for indexing to complete (watch bottom bar)"
echo "5. Press Cmd+B to build"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "⏳ Clearing caches..."

# Clear Xcode derived data
echo "  Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null

# Clear Xcode caches
echo "  Removing Xcode caches..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode 2>/dev/null
rm -rf ~/Library/Developer/Xcode/IndexStores 2>/dev/null

# Clear SPM caches
echo "  Removing SPM caches..."
rm -rf ~/.swiftpm/cache 2>/dev/null
rm -rf ~/.cache/swift-package-manager 2>/dev/null

# Remove Package.resolved
echo "  Removing Package.resolved files..."
cd "$(dirname "$0")"
find . -name "Package.resolved" -delete

echo ""
echo "✅ Cache cleared successfully!"
echo ""
echo "Next steps:"
echo "1. Close Xcode completely (Cmd+Q)"
echo "2. Reopen StudentStudyHaven.xcworkspace"
echo "3. Wait for indexing to complete"
echo "4. Press Cmd+B to build"
echo ""
