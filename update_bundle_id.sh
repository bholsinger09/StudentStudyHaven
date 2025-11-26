#!/bin/bash

# Script to update Bundle ID for iOS Student Haven project

echo "🔧 Updating Bundle ID for App Store deployment..."

# New unique Bundle ID
NEW_BUNDLE_ID="com.bholsinger.studentstudyhaven"

echo "New Bundle ID will be: $NEW_BUNDLE_ID"
echo ""
echo "⚠️  MANUAL STEPS REQUIRED IN XCODE:"
echo ""
echo "1. In Xcode, select your project in the navigator"
echo "2. Select the 'IOS_Studeent_Haven' target"
echo "3. Go to 'Signing & Capabilities' tab"
echo "4. Change Bundle Identifier to: $NEW_BUNDLE_ID"
echo ""
echo "5. Then in App Store Connect when creating the app:"
echo "   - Bundle ID: $NEW_BUNDLE_ID"
echo "   - SKU: STUDENTSTUDYHAVEN2025"
echo "   - App Name: Student Study Haven (or if taken: StudyHaven or My Study Haven)"
echo ""
echo "✅ After changing in Xcode, clean and rebuild:"
echo "   Product → Clean Build Folder (⇧⌘K)"
echo "   Product → Archive"
echo ""
