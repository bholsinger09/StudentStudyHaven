#!/bin/bash

echo "🧹 Cleaning old builds..."
rm -rf DerivedData
killall -9 StudentStudyHaven Xcode 2>/dev/null

echo "🏗️  Building with xcodebuild..."
xcodebuild -scheme StudentStudyHaven \
  -destination 'platform=macOS' \
  -configuration Debug \
  -derivedDataPath ./DerivedData \
  clean build

if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo "🚀 Looking for app bundle..."
  
  APP_PATH=$(find ./DerivedData -name "StudentStudyHaven.app" -type d | head -1)
  
  if [ -n "$APP_PATH" ]; then
    echo "📱 Found app at: $APP_PATH"
    open "$APP_PATH"
    echo "✅ App launched!"
  else
    echo "⚠️  No .app bundle found. Running executable directly..."
    EXEC_PATH=$(find ./DerivedData -name "StudentStudyHaven" -type f -perm +111 | grep -v dSYM | head -1)
    if [ -n "$EXEC_PATH" ]; then
      "$EXEC_PATH" &
      echo "✅ Executable running!"
    else
      echo "❌ Could not find executable"
    fi
  fi
else
  echo "❌ Build failed"
fi
