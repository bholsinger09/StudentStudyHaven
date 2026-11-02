# Phase 3: Completion Checklist

**Status**: In Progress - 1/8 Repositories Complete ✅

---

## Remaining Repository Implementations

### 1. ⏳ ClassRepositoryImpl
**Priority**: HIGH  
**Estimated Time**: 30 mins  
**Location**: `Sources/ClassManagement/Data/FirestoreClassRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getClasses(for userId) → Query classes
- ✅ getClass(by id) → Get single class
- ✅ createClass(_) → Create new class
- ✅ updateClass(_) → Update class
- ✅ deleteClass(id) → Delete class
- ✅ observeClasses(for userId) → Real-time publisher
- ✅ observeClassChanges(for userId) → Change publisher
- ✅ stopObserving()

**Firestore Collection**: `classes/{id}`  
**Template**: Use FirestoreStudyGroupRepositoryImpl as reference

---

### 2. ⏳ NoteRepositoryImpl
**Priority**: HIGH  
**Estimated Time**: 30 mins  
**Location**: `Sources/Notes/Data/FirestoreNoteRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getNotes(for classId) → Query notes by class
- ✅ getNote(by id) → Get single note
- ✅ getLinkedNotes(for noteId) → Get related notes
- ✅ createNote(_) → Create note
- ✅ updateNote(_) → Update note
- ✅ deleteNote(id) → Delete note
- ✅ searchNotes(query, classId) → Full-text search
- ✅ observeNotes(for classId) → Real-time
- ✅ observeNoteChanges(for classId) → Changes
- ✅ stopObserving()

**Firestore Collection**: `notes/{id}`  
**Note**: Search requires custom indexing in Firestore

---

### 3. ⏳ FlashcardRepositoryImpl
**Priority**: HIGH  
**Estimated Time**: 35 mins  
**Location**: `Sources/Flashcards/Data/FirestoreFlashcardRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getFlashcards(for classId) → Query flashcards
- ✅ getFlashcard(by id) → Get single
- ✅ createFlashcard(_) → Create one
- ✅ createFlashcards(_) → Batch create (use DatabaseService.batch)
- ✅ updateFlashcard(_) → Update
- ✅ deleteFlashcard(id) → Delete
- ✅ observeFlashcards(for classId) → Real-time
- ✅ observeFlashcardChanges(for classId) → Changes
- ✅ stopObserving()

**Firestore Collection**: `flashcards/{id}`  
**Special**: Handle ReviewData (nested struct) - Codable handles this!

---

### 4. ⏳ AssignmentRepositoryImpl
**Priority**: HIGHEST (Grade Tracking depends on this)  
**Estimated Time**: 35 mins  
**Location**: `Sources/GradeTracking/Data/FirestoreAssignmentRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getAssignments(for classId) → Query assignments
- ✅ getAssignment(by id) → Get single
- ✅ createAssignment(_) → Create
- ✅ updateAssignment(_) → Update (score updates here!)
- ✅ deleteAssignment(id) → Delete
- ✅ getUpcomingAssignments(daysAhead) → Query by dueDate
- ✅ getAssignmentsDue(by date, for classId) → Query by date
- ✅ observeAssignments(for classId) → Real-time
- ✅ observeAssignmentChanges(for classId) → Changes
- ✅ stopObserving()

**Firestore Collection**: `assignments/{id}`  
**Critical**: Grade calculations depend on this!

---

### 5. ⏳ UserRepositoryImpl (Verify/Complete)
**Priority**: MEDIUM  
**Estimated Time**: 20 mins  
**Location**: `Sources/Core/Data/FirestoreUserRepositoryImpl.swift`

**Status**: Partial implementation exists  
**Need to Verify**:
- ✅ getUser(by id) exists?
- ✅ getCurrentUser() implemented?
- ✅ updateUser(_) implemented?
- ✅ deleteUser(id) implemented?
- ✅ searchUsers(...) implemented?
- ✅ searchUsersByEmail(...) implemented?

**Firestore Collection**: `users/{id}`

---

### 6. ⏳ GroupStudySessionRepositoryImpl
**Priority**: MEDIUM  
**Estimated Time**: 30 mins  
**Location**: `Sources/StudyGroups/Data/FirestoreGroupStudySessionRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getStudySessions(for groupId) → Query sessions
- ✅ getUpcomingSessions(for userId) → Query upcoming
- ✅ getStudySession(by id) → Get single
- ✅ createStudySession(_) → Create
- ✅ updateStudySession(_) → Update
- ✅ deleteStudySession(id) → Delete
- ✅ addAttendee(sessionId, userId) → Add to array
- ✅ removeAttendee(sessionId, userId) → Remove from array
- ✅ observeStudySessions(for groupId) → Real-time
- ✅ observeStudySessionChanges(for sessionId) → Changes
- ✅ stopObserving()

**Firestore Collection**: `groupSessions/{id}`

---

### 7. ⏳ GroupMessageRepositoryImpl
**Priority**: MEDIUM  
**Estimated Time**: 30 mins  
**Location**: `Sources/StudyGroups/Data/FirestoreGroupMessageRepositoryImpl.swift`

**Methods to Implement**:
- ✅ getMessages(for groupId, limit) → Query with limit
- ✅ getMessage(by id) → Get single
- ✅ sendMessage(_) → Create (add timestamp)
- ✅ updateMessage(_) → Update
- ✅ deleteMessage(id) → Delete
- ✅ observeMessages(for groupId, limit) → Real-time
- ✅ observeNewMessages(for groupId) → Only new messages
- ✅ stopObserving()

**Firestore Collection**: `groupMessages/{id}`  
**Tip**: Remember to filter/limit in queries for performance

---

## Implementation Progress Tracking

```
Phase 3 Repositories: [1/8]

✅ StudyGroupRepositoryImpl        (COMPLETE - 100%)
⏳ ClassRepositoryImpl             (PENDING - 0%)
⏳ NoteRepositoryImpl              (PENDING - 0%)
⏳ FlashcardRepositoryImpl         (PENDING - 0%)
⏳ AssignmentRepositoryImpl        (PENDING - 0%)
⏳ UserRepositoryImpl              (PENDING - Verify)
⏳ GroupStudySessionRepositoryImpl (PENDING - 0%)
⏳ GroupMessageRepositoryImpl      (PENDING - 0%)
```

---

## Non-Repository Tasks

### [ ] Update DependencyContainer
**Task**: Verify all repositories default to Firebase  
**File**: `Sources/App/DependencyContainer.swift`  
**Time**: 15 mins

**Checklist**:
- [ ] All lazy properties return Firebase implementations
- [ ] useMockRepositories flag handled correctly
- [ ] No mocks in production code paths

### [ ] Deploy Firestore Security Rules
**Task**: Secure database access  
**File**: Firebase Console → Firestore Rules  
**Time**: 15 mins

**Rules Template**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default: only authenticated users
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
    
    // Optional: User-specific access
    match /classes/{classId} {
      allow read, create: if request.auth.uid != null;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }
  }
}
```

### [ ] Setup Firebase Project
**Tasks**:
- [ ] Create Firebase project (if new)
- [ ] Enable Firestore database
- [ ] Download GoogleService-Info.plist
- [ ] Add plist to Xcode project
- [ ] Verify Firebase initialization in iOSApp.swift
- [ ] Test Firebase connection

**Time**: 30-60 mins (depends on if new project)

---

## Testing Phase

### [ ] Manual Testing (Per Repository)

For each repository, test:
```swift
// 1. Create
let item = try await repo.create(testItem)
XCTAssertNotNil(item.id)

// 2. Read
let fetched = try await repo.get(by: item.id)
XCTAssertEqual(fetched.id, item.id)

// 3. Update
let updated = testItem
updated.name = "Updated Name"
let result = try await repo.update(updated)
XCTAssertEqual(result.name, "Updated Name")

// 4. Delete
try await repo.delete(id: item.id)
let notFound = try await repo.get(by: item.id) // Should throw

// 5. Real-time
let cancellable = repo.observe()
    .sink { items in
        XCTAssertNotNil(items)
    }
```

### [ ] Cross-Device Testing
**Once all repos are complete**:
- [ ] Test on simulator
- [ ] Test on physical device
- [ ] Verify real-time sync between devices
- [ ] Test offline mode and sync

### [ ] QR Code Join Feature Test
**Main validation test**:
- [ ] Create study group
- [ ] Generate QR code
- [ ] Scan from another device
- [ ] Verify member added in real-time
- [ ] Check Firestore document updated

---

## Build Status After Each Repository

**Command**: `swift build 2>&1 | grep -E "error|Build complete|Build failed"`

**Expected**: Build complete in < 30 seconds

---

## Timeline Estimate

| Task | Time | Status |
|------|------|--------|
| ClassRepositoryImpl | 30m | ⏳ |
| NoteRepositoryImpl | 30m | ⏳ |
| FlashcardRepositoryImpl | 35m | ⏳ |
| AssignmentRepositoryImpl | 35m | ⏳ |
| UserRepositoryImpl (verify) | 20m | ⏳ |
| GroupStudySessionRepositoryImpl | 30m | ⏳ |
| GroupMessageRepositoryImpl | 30m | ⏳ |
| Update DependencyContainer | 15m | ⏳ |
| Deploy Firestore Rules | 15m | ⏳ |
| Setup Firebase Project | 45m | ⏳ |
| Testing (all repos) | 60m | ⏳ |
| **TOTAL PHASE 3** | **~5.5 hrs** | **50% complete** |

---

## Reference: Implementation Template

```swift
import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

public class Firestore<Model>RepositoryImpl: <Model>RepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "<model>s"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // CRUD Implementation Pattern
    public func get<Model>(by id: String) async throws -> <Model> {
        return try await database.get(from: "\(collectionName)/\(id)", as: <Model>.self)
    }
    
    public func create(_ item: <Model>) async throws -> <Model> {
        try await database.set(item, at: "\(collectionName)/\(item.id)")
        return item
    }
    
    public func update(_ item: <Model>) async throws -> <Model> {
        guard let encoded = try? JSONEncoder().encode(item),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1)
        }
        dict["updatedAt"] = FieldValue.serverTimestamp()
        try await database.update("\(collectionName)/\(item.id)", with: dict)
        return item
    }
    
    public func delete(at path: String) async throws {
        try await database.delete(at: path)
    }
    
    // Real-time Pattern
    public func observe() -> AnyPublisher<[<Model>], Never> {
        let subject = CurrentValueSubject<[<Model>], Never>([])
        let listener = database.listenToCollection(collectionName, as: <Model>.self, 
            onUpdate: { items in subject.send(items) },
            onError: { _ in subject.send([]) })
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
}
```

---

## Next Steps

1. **Implement 7 remaining repositories** (~4 hours)
   - Follow template pattern
   - Test build after each one
   - Verify all methods implemented

2. **Deploy Firebase setup** (~45 mins)
   - Create/configure Firebase project
   - Download credentials
   - Deploy security rules

3. **Comprehensive testing** (~1 hour)
   - Manual CRUD tests for each repo
   - Real-time listener verification
   - QR code join feature test

4. **Ready for Phase 4**
   - Unit tests
   - Firestore emulator
   - Error handling enhancements

---

## Success Criteria for Phase 3 Completion

✅ All 8 repositories implemented and compiling  
✅ Build passes with zero errors  
✅ DependencyContainer uses Firebase implementations  
✅ Firestore security rules deployed  
✅ QR code join feature tested end-to-end  
✅ Cross-device sync verified  
✅ No mock repositories in production code paths  

---

## Ready to Continue?

The template is established. Each remaining repository is a straightforward adaptation of the StudyGroup pattern. Start with **ClassRepositoryImpl** - it's the simplest of the remaining 7.

Let's finish Phase 3! 🚀
