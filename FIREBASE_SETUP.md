# Firebase Setup Guide

## Quick Start (5 minutes)

### 1. Create Firebase Project
```
1. Visit https://console.firebase.google.com/
2. Click "Add Project" or "Create Project"
3. Enter project name: "StudentStudyHaven"
4. (Optional) Enable Google Analytics
5. Click "Create Project"
```

### 2. Add iOS App to Firebase
```
1. In Firebase Console, click the iOS icon to add an iOS app
2. iOS bundle ID: com.studyhaven.StudentStudyHaven
3. App nickname: StudentStudyHaven
4. Click "Register app"
5. Download GoogleService-Info.plist
6. IMPORTANT: Replace the template file in project root with your downloaded file
```

### 3. Enable Authentication
```
1. In Firebase Console sidebar, click "Authentication"
2. Click "Get Started"
3. Click "Sign-in method" tab
4. Click "Email/Password"
5. Enable "Email/Password"
6. Click "Save"
```

### 4. Create Firestore Database
```
1. In Firebase Console sidebar, click "Firestore Database"
2. Click "Create database"
3. Select "Start in test mode" (for development)
4. Choose location closest to you (e.g., us-central1)
5. Click "Enable"
```

### 5. Configure Security Rules
```
1. In Firestore Database, click "Rules" tab
2. Replace the default rules with the rules below
3. Click "Publish"
```

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection - users can only read/write their own document
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    // Classes collection - users can only access their own classes
    match /classes/{classId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Flashcards collection - users can only access their own flashcards
    match /flashcards/{flashcardId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Notes collection - users can only access their own notes
    match /notes/{noteId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
  }
}
```

### 6. Build and Run the App
```bash
# Navigate to project directory
cd /path/to/StudentStudyHaven

# Resolve dependencies (first time only, takes 2-3 minutes)
swift package resolve

# Build the project
swift build

# Run the app
swift run App
```

Or use Xcode:
```bash
# Open in Xcode
open Package.swift

# Then press ⌘R to build and run
```

## Verification Steps

### Test Authentication
1. Launch the app
2. Click "Register" or "Sign Up"
3. Enter email and password
4. Click "Register"
5. You should be logged in and see the main app

### Verify Firestore
1. Go to Firebase Console → Firestore Database
2. You should see collections appearing:
   - `users/` - after registration
   - `classes/` - after adding a class
   - `notes/` - after creating a note
   - `flashcards/` - after creating flashcards

### Test Offline Mode
1. Use the app and add some classes/notes
2. Turn off WiFi/cellular
3. Add more classes/notes (should work!)
4. Turn WiFi back on
5. Check Firestore - your offline changes should sync

## Troubleshooting

### "Firebase not configured" error
- Make sure you replaced the template GoogleService-Info.plist with your real one
- File should be at project root: `StudentStudyHaven/GoogleService-Info.plist`

### "Permission denied" errors
- Check that you published the security rules in Firestore
- Make sure you're signed in (check Authentication section in Firebase Console)

### Build errors
- Run `swift package clean` and `swift package resolve`
- Make sure you're using Swift 5.9+ and Xcode 15+

### Data not syncing
- Check internet connection
- Check Firebase Console → Firestore → Usage tab for errors
- Verify security rules allow your operations

## Optional: Firebase Emulator (For Testing)

### Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Initialize Project
```bash
cd /path/to/StudentStudyHaven
firebase login
firebase init emulators
# Select: Authentication, Firestore
```

### Start Emulators
```bash
firebase emulators:start
```

### Point App to Emulator
In `FirebaseManager.swift`, add after `FirebaseApp.configure()`:
```swift
#if DEBUG
Auth.auth().useEmulator(withHost: "localhost", port: 9099)
let settings = Firestore.firestore().settings
settings.host = "localhost:8080"
settings.isSSLEnabled = false
Firestore.firestore().settings = settings
#endif
```

## Production Checklist

Before deploying to production:
- [ ] Use production Firebase project (not dev)
- [ ] Update security rules for production
- [ ] Add GoogleService-Info.plist to .gitignore
- [ ] Enable App Check
- [ ] Set up monitoring and alerts
- [ ] Configure email templates
- [ ] Test on real devices
- [ ] Review Firestore indexes

## Support

- Firebase Documentation: https://firebase.google.com/docs
- Firebase Support: https://firebase.google.com/support
- Stack Overflow: Tag `firebase` or `google-cloud-firestore`

---

**Setup Time**: ~5-10 minutes
**Difficulty**: Easy
**Cost**: Free (Firebase Spark plan)
