# Phase 3: Implementation Guide

## Current State Analysis

### ✅ What We Have
1. **FirebaseIntegration module** with:
   - FirebaseService (initialization, singletons)
   - DatabaseService (generic CRUD, queries, listeners)
   - AuthService (authentication)
   - FirestoreHelper (collection refs, encoding/decoding)

2. **Repository Protocols** (8 total):
   - UserRepositoryProtocol
   - ClassRepositoryProtocol
   - FlashcardRepositoryProtocol
   - NoteRepositoryProtocol
   - StudyGroupRepositoryProtocol
   - GroupStudySessionRepositoryProtocol
   - GroupMessageRepositoryProtocol
   - AssignmentRepositoryProtocol

3. **Codable Models** (all complete):
   - User ✅ Codable
   - Class ✅ Codable
   - Flashcard ✅ Codable
   - Note ✅ Codable
   - StudyGroup ✅ Codable
   - Assignment ✅ Codable
   - (⚠️ CourseGradeInfo missing Codable)

4. **DependencyContainer** with mock repositories

### ❌ What's Missing
1. Firebase implementations of repositories using DatabaseService
2. Firestore security rules
3. CourseGradeInfo Codable conformance
4. Clear mapping of models to Firestore collections
5. Error handling patterns

---

## Firestore Schema

```
/studyGroups/{groupId}
  - id: string
  - name: string
  - classId: string
  - collegeId: string
  - description: string
  - createdBy: string (userId)
  - memberIds: array<string>
  - maxMembers: number (optional)
  - isPublic: boolean
  - createdAt: timestamp
  - updatedAt: timestamp

/classes/{classId}
  - id: string
  - userId: string
  - name: string
  - courseCode: string
  - schedule: array<{dayOfWeek, startTime, endTime}>
  - professor: string (optional)
  - location: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp

/notes/{noteId}
  - id: string
  - classId: string
  - userId: string
  - title: string
  - content: string
  - linkedNoteIds: array<string>
  - tags: array<string>
  - createdAt: timestamp
  - updatedAt: timestamp

/flashcards/{flashcardId}
  - id: string
  - classId: string
  - userId: string
  - front: string
  - back: string
  - noteIds: array<string>
  - lastReviewedAt: timestamp (optional)
  - reviewData: {repetitions, easeFactor, interval, nextReviewDate, lastReviewDate}
  - createdAt: timestamp
  - updatedAt: timestamp

/assignments/{assignmentId}
  - id: string
  - classId: string
  - name: string
  - dueDate: timestamp
  - description: string (optional)
  - score: number (optional)
  - maxScore: number
  - weight: number
  - type: string (Homework|Quiz|Exam|Project|Other)
  - createdAt: timestamp
  - updatedAt: timestamp

/users/{userId}
  - id: string
  - email: string
  - name: string
  - collegeId: string (optional)
  - createdAt: timestamp
  - updatedAt: timestamp
```

---

## Implementation Pattern

### Step 1: Update Collection Paths in FirestoreHelper

```swift
// In Sources/FirebaseIntegration/FirestoreHelper.swift

static let collections = (
    studyGroups: "studyGroups",
    classes: "classes",
    notes: "notes",
    flashcards: "flashcards",
    assignments: "assignments",
    users: "users",
    groupSessions: "groupSessions",
    groupMessages: "groupMessages"
)
```

### Step 2: Create Repository Implementation

Template pattern for all repositories:

```swift
import FirebaseIntegration
import Combine

public class FirestoreStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = FirestoreHelper.collections.studyGroups
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        let predicate = NSPredicate(format: "memberIds CONTAINS %@", userId)
        return try await database.query(
            from: collectionName,
            where: [predicate],
            as: StudyGroup.self
        )
    }
    
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: StudyGroup.self)
    }
    
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        let path = "\(collectionName)/\(studyGroup.id)"
        try await database.set(studyGroup, at: path)
        return studyGroup
    }
    
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        let path = "\(collectionName)/\(studyGroup.id)"
        try await database.update(path, with: encodedData(studyGroup))
        return studyGroup
    }
    
    public func deleteStudyGroup(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(from: path)
    }
    
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(groupId)"
        let updateData: [String: Any] = [
            "memberIds": FieldValue.arrayUnion([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudyGroup(by: groupId)
    }
    
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        let path = "\(collectionName)/\(groupId)"
        let updateData: [String: Any] = [
            "memberIds": FieldValue.arrayRemove([userId]),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await database.update(path, with: updateData)
        return try await getStudyGroup(by: groupId)
    }
    
    // MARK: - Real-time Listeners
    
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        let predicate = NSPredicate(format: "memberIds CONTAINS %@", userId)
        return database.observeCollection(
            from: collectionName,
            where: [predicate],
            as: StudyGroup.self
        )
        .replaceError(with: [])
        .eraseToAnyPublisher()
    }
    
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        let path = "\(collectionName)/\(groupId)"
        return database.observeDocument(
            at: path,
            as: StudyGroup.self
        )
        .compactMap { group in
            DataChange(id: groupId, value: group, type: .modified)
        }
        .replaceError(with: DataChange(id: groupId, value: nil, type: .removed))
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        database.stopAllListeners()
    }
    
    // MARK: - Helper
    
    private func encodedData(_ group: StudyGroup) -> [String: Any] {
        guard let encoded = try? JSONEncoder().encode(group),
              let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            return [:]
        }
        return dict
    }
}
```

### Step 3: Update DependencyContainer

```swift
public lazy var studyGroupRepository: StudyGroupRepositoryProtocol = {
    // Always use Firestore, no mock flag needed
    return FirestoreStudyGroupRepositoryImpl()
}()
```

---

## Task Checklist for Phase 3

### Part 1: Prepare (30 mins)
- [ ] Add Codable to CourseGradeInfo
- [ ] Verify all models conform to Codable
- [ ] Review FirebaseIntegration module components

### Part 2: Create Firebase Implementations (2-3 hours)
- [ ] Implement FirestoreStudyGroupRepositoryImpl
- [ ] Implement FirestoreClassRepositoryImpl
- [ ] Implement FirestoreNoteRepositoryImpl
- [ ] Implement FirestoreFlashcardRepositoryImpl
- [ ] Implement FirestoreAssignmentRepositoryImpl
- [ ] Implement FirestoreUserRepositoryImpl
- [ ] Implement FirestoreGroupStudySessionRepositoryImpl
- [ ] Implement FirestoreGroupMessageRepositoryImpl

### Part 3: Update Dependency Injection (30 mins)
- [ ] Update DependencyContainer to use Firestore implementations
- [ ] Remove useMockRepositories flag (or set default to false)
- [ ] Verify no mocks remain in production code paths

### Part 4: Firestore Setup (15 mins)
- [ ] Create Firebase project (if not done)
- [ ] Deploy security rules
- [ ] Set up Firestore collections

### Part 5: Testing (1-2 hours)
- [ ] Build project successfully
- [ ] Manual test: Create study group → Verify in Firestore
- [ ] Manual test: Join group → Verify member added
- [ ] Manual test: Create class → Verify in Firestore
- [ ] Manual test: Add assignment → Calculate GPA
- [ ] Test offline mode
- [ ] Test real-time listeners

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow only authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // More specific rules can be added:
    match /studyGroups/{groupId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth != null && 
                              (resource.data.createdBy == request.auth.uid || 
                               request.auth.uid in resource.data.memberIds);
    }
    
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
                                      resource.data.userId == request.auth.uid;
    }
    
    match /notes/{noteId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                             resource.data.userId == request.auth.uid;
    }
    
    match /flashcards/{flashcardId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                             resource.data.userId == request.auth.uid;
    }
    
    match /assignments/{assignmentId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
                                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Success Criteria

✅ All Firebase implementations complete
✅ Build succeeds with no errors
✅ Data persists to Firestore
✅ Real-time listeners work (see changes update live)
✅ QR code join updates group members in real-time
✅ All 8 repositories are Firestore-backed
✅ No mocks in production code
✅ Security rules deployed
✅ Manual end-to-end tests pass

---

## Rollback Plan

If critical issues arise:
1. Revert DependencyContainer to mocks
2. Set `useMockRepositories = true`
3. Continue debugging Firebase implementations
4. Use Firestore emulator for local testing

---

## Next Steps After Phase 3

1. Set up Firestore emulator for development
2. Add unit tests with mock DatabaseService
3. Add integration tests with emulator
4. Add error handling and retry logic
5. Create multi-environment setup

---

## Ready? Let's Build Phase 3! 🚀
