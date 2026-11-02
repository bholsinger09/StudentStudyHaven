# Build Instructions - StudentStudyHaven with Firebase

## Current Issue
The iOS Xcode project is separate from the Swift Package. This separation is causing linking issues.

## Solution: Proper Project Structure

### Option A: Keep Separate Projects (Recommended for Now)
If you want to keep the iOS project separate:

1. **Open the iOS project**:
   ```bash
   open StudentStudyHaven-iOS/StudentStudyHaven.xcodeproj
   ```

2. **Add Package Dependency in Xcode UI**:
   - Select Project: "StudentStudyHaven"
   - Go to "Package Dependencies" tab
   - Click "+" 
   - Add: `https://github.com/firebase/firebase-ios-sdk.git`
   - Version: Up to Next Major: 11.0.0

3. **Add to Build Phases**:
   - Select Target: "StudentStudyHaven"
   - Build Phases → Link Binary With Libraries
   - Add: App, Core, Authentication, ClassManagement, etc.

### Option B: Unified Xcode Project (Better Long-Term)
Merge the Swift Package into an Xcode project that also serves as the iOS app.

**Recommended approach** because:
✅ Single project file
✅ Easier dependency management
✅ Can build and archive directly
✅ Better Xcode IDE support
✅ Cleaner git history

## Next Step: Create Unified Xcode Project

We'll create a single Xcode project that:
1. Contains the app target (iOS)
2. Includes the Swift Package sources
3. Links Firebase properly
4. Can be built and archived without workarounds

This will be done next.
