#!/bin/bash
# Script to help locate the Xcode project used for App Store submission

echo "================================================"
echo "FINDING YOUR XCODE PROJECT"
echo "================================================"
echo ""

echo "Searching for Xcode projects (excluding build folders)..."
echo ""

# Search in common locations
PROJECTS=$(find ~ -name "*.xcodeproj" -not -path "*/.*" -not -path "*/build/*" -not -path "*/.build/*" -not -path "*/DerivedData/*" -not -path "*/Library/*" 2>/dev/null | head -20)

if [ -z "$PROJECTS" ]; then
    echo "❌ No Xcode projects found in common locations"
    echo ""
    echo "This could mean:"
    echo "1. The project was deleted"
    echo "2. It's in an unusual location"
    echo "3. You used a build service that created a temporary project"
    echo ""
else
    echo "Found these Xcode projects:"
    echo ""
    echo "$PROJECTS"
    echo ""
fi

echo "================================================"
echo "CHECKING XCODE ORGANIZER FOR ARCHIVES"
echo "================================================"
echo ""
echo "Looking for recently archived apps..."
ARCHIVES=$(find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -newermt "2024-01-01" 2>/dev/null | head -10)

if [ -z "$ARCHIVES" ]; then
    echo "❌ No recent archives found"
else
    echo "Found these recent archives:"
    echo ""
    for archive in $ARCHIVES; do
        # Get the archive name and date
        NAME=$(basename "$(dirname "$archive")")
        DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$archive" 2>/dev/null || date -r "$archive" "+%Y-%m-%d %H:%M" 2>/dev/null)
        echo "  📦 $NAME"
        echo "     Date: $DATE"
        echo "     Path: $archive"
        
        # Check the Info.plist in the archive
        INFO_PLIST="$archive/Info.plist"
        if [ -f "$INFO_PLIST" ]; then
            # Try to get the scheme name
            SCHEME=$(/usr/libexec/PlistBuddy -c "Print :SchemeName" "$INFO_PLIST" 2>/dev/null || echo "Unknown")
            echo "     Scheme: $SCHEME"
        fi
        echo ""
    done
fi

echo "================================================"
echo "NEXT STEPS"
echo "================================================"
echo ""
echo "To find which project was used:"
echo ""
echo "1. Open Xcode"
echo "2. Window → Organizer"
echo "3. Click 'Archives' tab"
echo "4. Find your StudentStudyHaven archive"
echo "5. Right-click → Show in Finder"
echo "6. The archive contains info about the source project"
echo ""
echo "Or check Xcode's recent projects:"
echo "7. In Xcode: File → Open Recent"
echo ""
echo "If you find the archive but not the project:"
echo "8. You may need to recreate the Xcode project"
echo "9. Run: ./create_ios_instructions.sh"
echo ""
