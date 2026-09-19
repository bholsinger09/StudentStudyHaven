#!/bin/bash

# StudentStudyHaven - Xcode Project Setup Script
# This script helps create a proper Xcode project that uses the Swift packages

set -e

echo "🎓 StudentStudyHaven - Xcode Project Setup"
echo "=========================================="
echo ""

# Use script directory as project root (works anywhere)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="StudentStudyHaven"
BUNDLE_ID="com.studyhaven.StudentStudyHaven"

cd "$PROJECT_DIR"

echo "📦 Current project structure created with modular Swift packages"
echo ""
echo "✅ Core module (Models, Protocols, Common)"
echo "✅ Authentication module (Login, Register, Use Cases)"
echo "✅ ClassManagement module (Classes, Schedules, Time Slots)"
echo "✅ Flashcards module (Generation, Review)"
echo "✅ Notes module (Note Taking, Linking)"
echo "✅ Comprehensive unit tests"
echo ""

echo "📱 To create an iOS app in Xcode:"
echo ""
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Select 'iOS' → 'App'"
echo "4. Configure:"
echo "   - Product Name: $APP_NAME"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Storage: None (we have our own data layer)"
echo "5. Save to: $PROJECT_DIR (choose 'Create' not 'Add to')"
echo "6. In Xcode:"
echo "   - Select project in navigator"
echo "   - Select app target"
echo "   - General tab → Frameworks, Libraries, and Embedded Content"
echo "   - Click '+' and add local packages:"
echo "     * Core"
echo "     * Authentication"  
echo "     * ClassManagement"
echo "     * Flashcards"
echo "     * Notes"
echo ""

echo "🧪 To run tests without Xcode:"
echo "   swift test"
echo ""

echo "📖 See SETUP.md for detailed instructions"
echo ""
echo "✨ Project structure ready for development!"
