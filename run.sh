#!/bin/bash

# Quick run script for StudentStudyHaven macOS app
# This builds and immediately launches the app

set -e

echo "🏗️  Building and launching StudentStudyHaven..."

# Kill any existing instance
pkill StudentStudyHaven 2>/dev/null || true

# Build
./build_app.sh

# Launch
echo "🚀 Launching app..."
open .build/app/StudentStudyHaven.app

echo "✅ App launched!"
