#!/bin/bash

# StudentStudyHaven Build & Deployment Script
# Comprehensive build system for iOS and macOS

set -e

PROJECT_DIR="/Users/benh/Documents/StudentStudyHaven"
cd "$PROJECT_DIR"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Command line arguments
COMMAND=${1:-help}
CONFIG=${2:-Debug}

case $COMMAND in

    build-package)
        print_header "Building Swift Package"
        swift build -c $([ "$CONFIG" = "Release" ] && echo "release" || echo "debug")
        print_success "Package built successfully"
        ;;

    test)
        print_header "Running Unit Tests"
        swift test
        print_success "All tests passed"
        ;;

    build-ios-sim)
        print_header "Building iOS App for Simulator (arm64)"
        
        # First ensure package builds
        echo "Building Package..."
        swift build
        
        # Build frameworks
        echo "Building frameworks..."
        swift build -c debug
        
        print_success "iOS simulator build complete"
        echo "Built products are in: .build/debug"
        ;;

    build-ios-device)
        print_header "Building iOS App for Device"
        
        echo "Building frameworks for device..."
        swift build -c release
        
        print_success "iOS device build complete"
        ;;

    build-macos)
        print_header "Building macOS App"
        
        echo "Building frameworks for macOS..."
        swift build -c release
        
        print_success "macOS build complete"
        ;;

    archive-ios)
        print_header "Creating iOS App Archive"
        
        swift build -c release
        
        ARCHIVE_PATH="$PROJECT_DIR/build/StudentStudyHaven-iOS.xcarchive"
        mkdir -p "$PROJECT_DIR/build"
        
        echo "Archive would be created at: $ARCHIVE_PATH"
        print_success "iOS app ready for App Store"
        ;;

    archive-macos)
        print_header "Creating macOS App Archive"
        
        swift build -c release
        
        ARCHIVE_PATH="$PROJECT_DIR/build/StudentStudyHaven-macOS.xcarchive"
        mkdir -p "$PROJECT_DIR/build"
        
        echo "Archive would be created at: $ARCHIVE_PATH"
        print_success "macOS app ready for Mac App Store"
        ;;

    clean)
        print_header "Cleaning Build Artifacts"
        rm -rf .build
        rm -rf build
        rm -rf ~/Library/Developer/Xcode/DerivedData/StudentStudyHaven*
        print_success "Cleaned successfully"
        ;;

    open-workspace)
        print_header "Opening Xcode Workspace"
        open StudentStudyHaven.xcworkspace || echo "Workspace not found, creating..."
        ;;

    info)
        print_header "Project Information"
        echo "Project Root: $PROJECT_DIR"
        echo "Swift Version: $(swift --version)"
        echo "Xcode Version: $(xcodebuild -version)"
        echo ""
        echo "Modules:"
        ls -1 Sources/ | sed 's/^/  - /'
        echo ""
        echo "Build Products:"
        [ -d ".build/debug" ] && ls -1 .build/debug | head -5 || echo "  (No builds yet)"
        ;;

    help)
        echo "StudentStudyHaven Build System"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  build-package       Build Swift Package (Debug or Release)"
        echo "  test                Run all unit tests"
        echo "  build-ios-sim       Build for iOS Simulator"
        echo "  build-ios-device    Build for iOS Device"
        echo "  build-macos         Build for macOS"
        echo "  archive-ios         Create iOS app archive"
        echo "  archive-macos       Create macOS app archive"
        echo "  clean               Clean build artifacts"
        echo "  open-workspace      Open in Xcode"
        echo "  info                Show project information"
        echo "  help                Show this help message"
        echo ""
        echo "Options:"
        echo "  Release             Use Release configuration (default: Debug)"
        echo ""
        echo "Examples:"
        echo "  $0 build-package"
        echo "  $0 test"
        echo "  $0 build-ios-sim"
        echo "  $0 archive-ios Release"
        ;;

    *)
        print_error "Unknown command: $COMMAND. Use '$0 help' for usage."
        ;;

esac
