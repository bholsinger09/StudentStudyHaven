# Firebase Integration - Long-Term Architecture Plan

## Overview
Build StudentStudyHaven with **Firebase as primary backend** from day one, ensuring clean separation of concerns and maintainability.

## Architecture Principles

1. **Single Source of Truth**: Firebase Firestore is the primary database
2. **Repository Pattern**: All data access goes through repository interfaces
3. **Dependency Injection**: Repositories injected at app startup
4. **No Mock Code in Production**: Mock implementations only in tests
5. **Clean Separation**: Backend logic separate from UI/presentation

## Phase 1: Foundation (Current)
**Goal**: Get the project building and establish clean Firebase integration

### 1.1 Project Structure
```
StudentStudyHaven/
├── Package.swift                 # Swift Package definition
├── Sources/
│   ├── App/                     # App entry points
│   ├── Core/                    # Core domain types
│   ├── Authentication/          # Auth module (Firebase Auth)
│   ├── StudyGroups/            # Study Groups module (Firestore)
│   ├── ClassManagement/        # Class Management module (Firestore)
│   ├── Flashcards/             # Flashcards module (Firestore)
│   ├── Notes/                  # Notes module (Firestore)
│   ├── GradeTracking/          # Grade Tracking module (Firestore)
│   └── Firebase/               # NEW: Firebase service layer
│       ├── FirebaseService.swift    # Core Firebase initialization
│       ├── FirestoreHelper.swift    # Firestore utilities
│       └── AuthService.swift        # Authentication wrapper
├── StudentStudyHaven-iOS/       # iOS app target
├── StudentStudyHaven-macOS/     # macOS app target
└── Tests/

```

### 1.2 Firebase Service Layer
Create a new `Sources/Firebase/` module that handles:
- Firebase initialization (without hardcoding)
- Firestore connection
- Authentication state management
- Error handling
- Offline support

### 1.3 Repository Implementation
Each module implements repository interfaces using Firestore:
- **Authentication Module**: Uses Firebase Auth
- **StudyGroups**: Firestore collection: `studyGroups`
- **ClassManagement**: Firestore collection: `classes`
- **Flashcards**: Firestore collection: `flashcards`
- **Notes**: Firestore collection: `notes`
- **GradeTracking**: Firestore collection: `grades`

## Phase 2: Firebase Configuration
**Goal**: Proper secrets management without exposing credentials

### 2.1 GoogleService-Info.plist
- File is app-specific (iOS, macOS apps generate their own)
- Add to `.gitignore` (done ✓)
- Developers get their own copy from Firebase Console
- CI/CD: Store as secret, injected at build time

### 2.2 Environment Configuration
```swift
// Sources/Firebase/FirebaseConfig.swift
struct FirebaseConfig {
    static let projectId = "studenthaven-def67"
    // Other non-secret config here
}
```

## Phase 3: Data Models & Repositories
**Goal**: Clean interfaces, Firestore-backed implementations

### 3.1 Example: StudyGroup Repository
```swift
// In Sources/StudyGroups/Domain/
protocol StudyGroupRepository {
    func createGroup(_ group: StudyGroup) async throws
    func getGroup(_ id: String) async throws -> StudyGroup
    func joinGroup(_ groupId: String, userId: String) async throws
    // etc.
}

// In Sources/Firebase/ or Sources/StudyGroups/Data/
class FirestoreStudyGroupRepository: StudyGroupRepository {
    // Implement using Firestore
}
```

### 3.2 Firestore Schema
```
studyGroups/
  {groupId}/
    name: string
    description: string
    members: [userId]
    qrCode: string
    createdBy: userId
    createdAt: timestamp

classes/
  {classId}/
    name: string
    professor: string
    meetingTimes: [...]
    
grades/
  {gradeId}/
    userId: string
    classId: string
    assignmentName: string
    score: number
```

## Phase 4: Dependency Injection
**Goal**: Clean initialization, testable code

```swift
// Sources/App/DependencyContainer.swift
class DependencyContainer {
    static let shared = DependencyContainer()
    
    // Firebase-backed repositories
    lazy var studyGroupRepository: StudyGroupRepository = {
        FirestoreStudyGroupRepository()
    }()
    
    lazy var classRepository: ClassRepository = {
        FirestoreClassRepository()
    }()
    // ... other repositories
}

// In App initialization
@main
struct iOSApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // All repositories now use Firebase
        // No mock code in production
    }
}
```

## Phase 5: Testing Strategy
**Goal**: Testable code without mocking production repositories

### 5.1 Unit Tests
- Test business logic with mock repositories
- Mock repositories ONLY in test targets
- No mocks in production code

### 5.2 Integration Tests
- Use Firestore emulator (local development)
- Real Firestore against staging project for integration

### 5.3 E2E Tests
- Test on simulator and real device with staging Firebase project

## Implementation Steps

### Step 1: Add Firebase to Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", 
             .upToNextMajor(from: "11.0.0")),
]
```

### Step 2: Create Firebase Module
```
Sources/Firebase/
├── FirebaseService.swift      // Initialize Firebase
├── FirestoreHelper.swift      // Firestore utilities
├── Models/                    // Firestore model mappings
└── Repositories/              // Firestore repository implementations
```

### Step 3: Update Each Module's Repository
- Remove mock implementations or move to tests
- Implement using Firestore
- Update DependencyContainer

### Step 4: Update App Entry Points
- Remove mock initialization
- Initialize Firebase properly
- Use real repositories

### Step 5: Set Up Secrets Management
- Store GoogleService-Info.plist outside repo (✓ in .gitignore)
- CI/CD: Inject at build time
- Local: Each developer gets from Firebase Console

## Security & Best Practices

### 5.1 Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

### 5.2 Credential Management
- ✓ GoogleService-Info.plist in .gitignore
- ✓ No hardcoded Firebase keys in code
- ✓ Use Firebase Console for project management
- ✓ CI/CD builds get credentials from secrets

### 5.3 API Keys
- Firebase API Key is embedded in GoogleService-Info.plist
- It's restricted to your bundle ID (safe)
- Only enables Firebase services you've enabled

## Build & Release

### Debug Builds
1. Open `StudentStudyHaven-iOS/StudentStudyHaven.xcodeproj`
2. Build with Cmd+B
3. Uses GoogleService-Info.plist from project folder
4. Connects to Firebase development project

### Release Builds (App Store)
1. Same project file
2. Can use different Firebase project via different GoogleService-Info.plist
3. Build archive with Cmd+B, then Product → Archive
4. Upload to App Store

## Timeline

- **Week 1**: Foundation + Firebase module (current)
- **Week 2**: Firestore schema + repository implementations
- **Week 3**: Testing + integration
- **Week 4**: Refinement + documentation

## Success Criteria

✅ Single Xcode project (no workspaces)
✅ Clean Firebase integration
✅ No mock code in production
✅ Can build and archive for App Store
✅ Secure credential handling
✅ Testable architecture
✅ Clear data flow (UI → Repository → Firestore)
