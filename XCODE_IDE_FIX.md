# Xcode IDE vs CLI Build Issue - Fix Guide

## Problem
- ✅ CLI builds succeed: `xcodebuild` compiles without errors
- ❌ Xcode UI shows linker errors: "Undefined symbol", "Could not find framework"
- ❌ Cannot build from Xcode GUI

## Root Cause
Xcode IDE uses a different build system than xcodebuild CLI:
- CLI: Direct compilation and linking, fresh build each time
- IDE: Uses indexer, caches, and may reuse old artifacts

When there are major changes (new modules, deleted files, pbxproj changes), Xcode's cache gets out of sync.

## Solution: Complete Xcode Reset

### Step 1: Close All Xcode Windows
```
Cmd+Q to quit Xcode completely
```

### Step 2: Clear All Caches
```bash
# Delete Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Delete Xcode caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Developer/Xcode/IndexStores

# Delete SPM caches
rm -rf ~/.swiftpm/cache
rm -rf ~/.cache/swift-package-manager

# Remove Package.resolved lock files
cd /Users/benh/Documents/StudentStudyHaven
find . -name "Package.resolved" -delete
```

### Step 3: Reopen Xcode
1. Open `StudentStudyHaven-iOS/StudentStudyHaven.xcworkspace` in Xcode
2. **WAIT FOR INDEXING TO COMPLETE** (watch the bottom toolbar - should say "Indexing Complete")
3. This usually takes 2-5 minutes
4. Do NOT try to build until indexing is done

### Step 4: Clean Build Folder
1. In Xcode: Shift+Cmd+K (or Product > Clean Build Folder)
2. Wait for clean to complete

### Step 5: Build from Xcode UI
1. Select iPhone 16 simulator as build target
2. Press Cmd+B to build
3. Should now succeed (or show real compilation errors, not indexer errors)

## Why This Works

Xcode's indexer reads the pbxproj and builds a symbol database. When this gets corrupted or out of sync:
- IDE can't find module definitions
- IDE can't link properly
- IDE shows "undefined symbol" errors

A full cache clear + reindex rebuilds the symbol database from scratch, matching what the CLI build sees.

## If Still Failing After Reset

### Option A: Build from CLI Only
```bash
cd StudentStudyHaven-iOS
xcodebuild -workspace StudentStudyHaven.xcworkspace \
  -scheme StudentStudyHaven \
  -configuration Debug \
  -sdk iphonesimulator
```
Then run tests/simulator from there.

### Option B: Check for Real Issues
If both CLI and IDE fail after reset, there's a real build issue:
1. Check build logs in Xcode (Cmd+9)
2. Look for actual compilation errors (not indexer errors)
3. These will show line numbers and file names

### Option C: Regenerate Xcode Project
Last resort if pbxproj is corrupted:
```bash
# Backup current
cp -r StudentStudyHaven-iOS StudentStudyHaven-iOS.bak

# Remove and let xcodebuild regenerate
rm -rf StudentStudyHaven-iOS
xcodebuild -workspace StudentStudyHaven.xcworkspace -list
```

## Verification

After Xcode rebuild:
- [ ] Xcode shows no red error circles on imports
- [ ] Can Cmd+Click on App to navigate to definition
- [ ] Build completes successfully (Cmd+B)
- [ ] App runs on simulator without crashes

---
**Note:** This issue is ONLY with Xcode IDE, not the actual app.  The app IS building correctly via CLI and runs fine on the simulator.
