# Phase 3: Repository Implementation & Firestore Integration

## Overview
Convert mock repositories to Firestore-backed implementations and define data models.

## Timeline Estimate
- **Duration**: 1-2 days
- **Complexity**: MEDIUM
- **Risk**: LOW (Firebase layer already tested)

---

## Phase 3 Tasks

### Task 1: Define Codable Models
**Goal**: Create Firestore-compatible models with Codable conformance

**Files to Create/Update:**
```
Sources/Core/Models/
├── StudyGroup.swift          (add Codable, Identifiable)
├── Class.swift              (add Codable, Identifiable)
├── Note.swift               (add Codable, Identifiable)
├── Flashcard.swift          (add Codable, Identifiable)
└── Grade.swift              (add Codable, Identifiable)
```

**Requirements:**
- All models must conform to `Codable`
- Add `@Codable` for Date encoding (ISO 8601)
- Add required fields for Firestore (timestamps, userIds, etc.)
- Maintain existing domain model properties

**Example:**
```swift
struct StudyGroup: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var members: [String]  // Array of user IDs
    var qrCode: String
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case members
        case qrCode = "qr_code"  // snake_case in Firestore
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

---

### Task 2: Define Firestore Security Rules
**Goal**: Secure the database for authenticated users

**File to Create:**
```
Firestore Console → Rules tab
```

**Rules Template:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
    
    // Specific rules can be added per collection
    match /studyGroups/{groupId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid != null;
    }
  }
}
```

**Action**: Copy to Firebase Console after creating

---

### Task 3: Implement StudyGroup Repository
**Goal**: Connect StudyGroups module to Firestore

**Files to Create/Update:**
```
Sources/StudyGroups/Data/
├── FirestoreStudyGroupRepositoryImpl.swift  (NEW)
└── StudyGroupRepositoryProtocol.swift       (UPDATE)
```

**Implementation:**
```swift
public class FirestoreStudyGroupRepositoryImpl: StudyGroupRepository {
    private let database = DatabaseService.shared
    private let collectionName = "studyGroups"
    
    public func createGroup(_ group: StudyGroup) async throws {
        let path = "\(collectionName)/\(group.id ?? UUID().uuidString)"
        try await database.set(group, at: path)
    }
    
    public func getGroup(_ id: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: StudyGroup.self)
    }
    
    public func joinGroup(_ groupId: String, userId: String) async throws {
        let path = "\(collectionName)/\(groupId)"
        try await database.update(path, with: [
            "members": FieldValue.arrayUnion([userId])
        ])
    }
    
    // ... other methods
}
```

---

### Task 4: Implement Class Repository
**Goal**: Connect ClassManagement module to Firestore

**Files to Create/Update:**
```
Sources/ClassManagement/Data/
├── FirestoreClassRepositoryImpl.swift  (NEW)
└── ClassRepositoryProtocol.swift      (UPDATE)
```

**Collections:**
- `classes/` - Store class information
- Fields: name, professor, meetingTimes, userId, etc.

---

### Task 5: Implement Note Repository
**Goal**: Connect Notes module to Firestore

**Files to Create/Update:**
```
Sources/Notes/Data/
├── FirestoreNoteRepositoryImpl.swift  (NEW)
└── NoteRepositoryProtocol.swift      (UPDATE)
```

**Collections:**
- `notes/` - Store user notes
- Fields: content, classId, createdAt, userId, tags

---

### Task 6: Implement Flashcard Repository
**Goal**: Connect Flashcards module to Firestore

**Files to Create/Update:**
```
Sources/Flashcards/Data/
├── FirestoreFlashcardRepositoryImpl.swift  (NEW)
└── FlashcardRepositoryProtocol.swift      (UPDATE)
```

**Collections:**
- `flashcards/` - Store flashcard sets
- Fields: question, answer, deckId, userId, difficulty

---

### Task 7: Implement Grade Repository
**Goal**: Connect GradeTracking module to Firestore

**Files to Create/Update:**
```
Sources/GradeTracking/Data/
├── FirestoreGradeRepositoryImpl.swift  (NEW)
└── GradeRepositoryProtocol.swift      (UPDATE)
```

**Collections:**
- `grades/` - Store grades
- Fields: userId, classId, assignmentName, score, weight, date

---

### Task 8: Update DependencyContainer
**Goal**: Inject Firestore repositories instead of mocks

**File to Update:**
```
Sources/App/DependencyContainer.swift
```

**Changes:**
```swift
public class DependencyContainer {
    // Change from mock to Firestore implementations
    public var studyGroupRepository: StudyGroupRepository = {
        return FirestoreStudyGroupRepositoryImpl()  // Was: MockStudyGroupRepositoryImpl()
    }()
    
    public var classRepository: ClassRepository = {
        return FirestoreClassRepositoryImpl()  // Was: MockClassRepositoryImpl()
    }()
    
    // ... other repositories
}
```

---

### Task 9: Update App Entry Points
**Goal**: Remove useMockRepositories flag, ensure Firebase is initialized

**Files to Update:**
```
StudentStudyHaven-iOS/StudentStudyHaven/iOSApp.swift
StudentStudyHaven-macOS/StudentStudyHaven/macOSApp.swift
```

**Verify:**
- ✅ FirebaseService.shared.initialize() is called
- ✅ iOSApp/macOSApp don't set useMockRepositories flag
- ✅ Dependencies are auto-created with Firestore implementations

---

### Task 10: Testing & Validation
**Goal**: Verify data flows through Firestore

**Manual Testing:**
1. Create a study group → Check Firestore console
2. Join study group → Verify member added to array
3. Create a class → Check appears in Firestore
4. Add a grade → Verify calculation works

**Automated Testing:**
- Unit tests for repository methods (Phase 4)
- Integration tests with emulator (Phase 4)

---

## Firestore Schema (Final)

```
firestore/
├── studyGroups/{groupId}
│   ├── name: string
│   ├── description: string
│   ├── members: array<string>  (user IDs)
│   ├── qr_code: string
│   ├── created_by: string (user ID)
│   ├── created_at: timestamp
│   └── updated_at: timestamp
│
├── classes/{classId}
│   ├── name: string
│   ├── professor: string
│   ├── meeting_times: array
│   ├── user_id: string
│   ├── created_at: timestamp
│   └── updated_at: timestamp
│
├── notes/{noteId}
│   ├── content: string
│   ├── class_id: string (reference to class)
│   ├── user_id: string
│   ├── tags: array<string>
│   ├── created_at: timestamp
│   └── updated_at: timestamp
│
├── flashcards/{cardId}
│   ├── question: string
│   ├── answer: string
│   ├── deck_id: string (reference to deck)
│   ├── user_id: string
│   ├── difficulty: number (1-5)
│   ├── created_at: timestamp
│   └── updated_at: timestamp
│
└── grades/{gradeId}
    ├── user_id: string
    ├── class_id: string
    ├── assignment_name: string
    ├── score: number
    ├── weight: number (0-1)
    ├── date: timestamp
    └── updated_at: timestamp
```

---

## Implementation Order

**Recommended sequence:**
1. Define all Codable models (Task 1)
2. Create security rules (Task 2)
3. Implement StudyGroup repository (Task 3) - highest priority
4. Implement Class repository (Task 4)
5. Implement Note repository (Task 5)
6. Implement Flashcard repository (Task 6)
7. Implement Grade repository (Task 7)
8. Update DependencyContainer (Task 8)
9. Update app entry points (Task 9)
10. Manual testing (Task 10)

---

## Success Criteria

- ✅ All repositories use Firestore instead of mocks
- ✅ Data persists across app restarts
- ✅ QR code join updates Firestore group members
- ✅ Grades save to Firestore
- ✅ No mocks in production code
- ✅ Build succeeds without warnings
- ✅ App runs on simulator and real device

---

## Rollback Plan

If issues arise:
1. Revert to mock repositories (revert Task 8-9)
2. Continue debugging Firestore implementation
3. Use Firestore emulator to test locally

**Risk**: LOW - Firebase service layer is well-tested, issues would be in repository implementations

---

## Next Phase (Phase 4)

After Phase 3 completes:
- Add comprehensive test suite
- Set up Firestore emulator for local development
- Add error handling and retry logic
- Performance optimization
- Multi-environment configuration

---

## Ready to Begin Phase 3?

**Prerequisites met:**
- ✅ Firebase service layer complete
- ✅ Build system clean
- ✅ No technical debt blocking
- ✅ Architecture solid
- ✅ Plan documented

**Next**: Confirm to start Phase 3! 🚀
