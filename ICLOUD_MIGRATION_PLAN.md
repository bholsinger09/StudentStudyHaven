# iCloud (CloudKit) Migration Plan

## Decision Point
**Date:** 2026-11-02
**Reason:** Xcode IDE has fundamental indexing/caching issues that prevent building from GUI. CLI builds work perfectly, but can't archive/sign for App Store without Xcode UI.

**Solution:** Migrate from Firebase/Firestore to iCloud/CloudKit for cleaner iOS integration and to resolve Xcode build issues.

---

## Architecture Changes

### Authentication
**Firebase → iCloud:**
```
Firebase Auth           → iCloud Account Sign-In
email/password login    → User's Apple ID
User.uid                → CKRecord.recordID.recordName
Firestore user docs     → CKRecord in UserZone
```

### Database
**Firestore → CloudKit:**
```
Firestore collections   → CKDatabase (public/private/shared)
Firestore docs          → CKRecord
Real-time listeners     → CKQuerySubscription
Batch writes            → CKModifyRecordsOperation
Field queries           → CKQuery + NSPredicate
```

### Grade Tracker Data Model
```
CloudKit Schema:

PUBLIC ZONE:
  ├── User (CKRecord)
  │   ├── recordID: user's iCloud ID
  │   ├── name: String
  │   ├── email: String
  │   └── avatar: CKAsset
  │
  ├── Class (CKRecord)
  │   ├── classID: UUID
  │   ├── name: String
  │   ├── instructor: Reference → User
  │   ├── semester: String
  │   ├── credits: Int
  │   └── targetGrade: String
  │
  ├── Assignment (CKRecord)
  │   ├── assignmentID: UUID
  │   ├── classID: Reference → Class
  │   ├── title: String
  │   ├── type: String (homework/quiz/exam/project)
  │   ├── dueDate: Date
  │   ├── pointsEarned: Double
  │   ├── pointsTotal: Double
  │   ├── weight: Double
  │   └── submittedDate: Date
  │
  ├── Grade (CKRecord)
  │   ├── gradeID: UUID
  │   ├── classID: Reference → Class
  │   ├── numericalGrade: Double
  │   ├── letterGrade: String
  │   ├── calculatedAt: Date
  │   └── components: [Assignment IDs]
  │
  └── GPA (CKRecord)
      ├── gpaID: UUID
      ├── userID: Reference → User
      ├── overallGPA: Double
      ├── semesterGPA: Double
      ├── calculatedAt: Date
      └── classGrades: [Class IDs]

SHARED ZONE (for study groups):
  ├── StudyGroup (CKRecord)
  │   ├── groupID: UUID
  │   ├── name: String
  │   ├── creator: Reference → User
  │   ├── members: [User IDs]
  │   ├── createdAt: Date
  │   └── qrCode: String
  │
  └── GroupAssignment (CKRecord)
      ├── groupID: Reference → StudyGroup
      ├── assignment: Reference → Assignment
      ├── sharedByUser: Reference → User
      └── sharedAt: Date
```

---

## Migration Phases

### Phase 1: CloudKit Infrastructure (Day 1)
- [ ] Set up CloudKit container in entitlements
- [ ] Create CloudKit schema (User, Class, Assignment, Grade, GPA)
- [ ] Implement CloudKit manager (singleton like FirebaseService)
- [ ] Set up private database access
- [ ] Test basic CRUD operations

### Phase 2: Authentication (Day 1-2)
- [ ] Remove Firebase Auth
- [ ] Implement iCloud Sign-in flow
- [ ] Handle user identification
- [ ] Store user metadata in CloudKit
- [ ] Handle sign-out

### Phase 3: Grade Tracker Migration (Day 2-3)
- [ ] Migrate Class model to CloudKit
- [ ] Migrate Assignment model to CloudKit
- [ ] Migrate Grade model to CloudKit
- [ ] Migrate GPA model to CloudKit
- [ ] Implement CloudKit fetch/save operations
- [ ] Add offline caching with NSUbiquitousKeyValueStore or Core Data

### Phase 4: Study Groups (Day 3)
- [ ] Migrate StudyGroup to CloudKit Shared Zone
- [ ] Implement QR code group invitations
- [ ] Handle group member management
- [ ] Test multi-user group access

### Phase 5: Sync & Notifications (Day 3)
- [ ] Implement CloudKit subscriptions
- [ ] Handle remote notifications
- [ ] Add background sync with BGProcessingTaskRequest

### Phase 6: Testing & Polish (Day 4)
- [ ] Comprehensive testing in Xcode
- [ ] Archive to TestFlight
- [ ] Final UI/UX polish

---

## Code Structure Changes

### Remove
- `Sources/FirebaseIntegration/` (entire module)
- Firebase from Package.swift
- All Firebase imports

### Add
```
Sources/
├── iCloudIntegration/
│   ├── CloudKitManager.swift (singleton)
│   ├── CloudKitModels.swift (CKRecord extensions)
│   ├── CloudKitUser.swift
│   ├── CloudKitSync.swift
│   └── CloudKitSubscriptions.swift
├── GradeTracking/ (modify for CloudKit)
│   ├── Models/ → CKRecord adapters
│   ├── Repository/ → CloudKit operations
│   └── Services/ → Sync logic
└── StudyGroups/ (modify for CloudKit Shared Zone)
```

### Modify
- `App/DependencyContainer.swift` - Remove FirebaseService, add CloudKitManager
- `iOSApp.swift` - Remove Firebase init, add iCloud sign-in
- All data models - Add CKRecord encoding/decoding

---

## Package.swift Changes

### Remove
```swift
.package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
```

### Keep
```swift
// CloudKit is built-in to iOS, no external dependency needed!
// Just use: import CloudKit
```

---

## Critical CloudKit Features to Implement

### 1. User Authentication
```swift
CKContainer.default().accountStatus { status, error in
    if status == .available {
        CKContainer.default().requestApplicationPermission(...) { status, error in
            // Save user record to CloudKit
        }
    }
}
```

### 2. Data Sync
```swift
// CloudKit handles sync automatically when using CKDatabase
// Just save to private database:
let database = CKContainer.default().privateCloudDatabase
database.save(record) { record, error in ... }
```

### 3. Offline Support
```swift
// Use NSUbiquitousKeyValueStore for offline access
// Sync when connection returns
UserDefaults(suiteName: "group.com.bholsinger.studentstudyhaven")?.setValue(...)
```

### 4. Subscriptions (Real-time updates)
```swift
let subscription = CKQuerySubscription(recordType: "Grade", predicate: NSPredicate(format: "TRUE"))
let notificationInfo = CKSubscription.NotificationInfo()
subscription.notificationInfo = notificationInfo
database.save(subscription) { _, error in ... }
```

---

## Advantages of CloudKit

✅ **Built into iOS** - No external dependency, no version conflicts
✅ **Tight Apple integration** - Works seamlessly with App Store
✅ **Xcode support** - Full IDE integration, no indexing issues
✅ **Automatic sync** - CloudKit handles sync to all user devices
✅ **Secure by default** - Uses iCloud account as auth
✅ **Easy archiving** - No special build configuration
✅ **Better offline support** - NSUbiquitousKeyValueStore + local caching

## Disadvantages vs Firebase

❌ **Simpler query model** - Can't do complex nested queries like Firestore
❌ **Smaller ecosystem** - Fewer third-party tools
❌ **Apple-only** - Can't easily support Android later
❌ **Less real-time** - Slight delay in subscriptions
❌ **Limited dashboard** - iCloud Console is basic

---

## Timeline
- **Day 1:** CloudKit setup + Authentication
- **Day 2:** Grade Tracker models & CRUD
- **Day 3:** Study Groups + Subscriptions  
- **Day 4:** Testing + Polish + Archive to TestFlight

---

## Next Step
Start Phase 1: Set up CloudKit container and basic infrastructure.
