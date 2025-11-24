# StudentStudyHaven - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Module Descriptions](#module-descriptions)
3. [Testing Strategy](#testing-strategy)
4. [Data Flow](#data-flow)
5. [API Reference](#api-reference)

## Architecture Overview

StudentStudyHaven follows **Clean Architecture** principles with three distinct layers:

### Layer 1: Domain (Core Module)
- **Purpose**: Define business entities and rules
- **Dependencies**: None
- **Components**:
  - Models (User, College, Class, Flashcard, Note)
  - Repository Protocols
  - Error Types
  - Common utilities

### Layer 2: Business Logic (Use Cases)
- **Purpose**: Application-specific business rules
- **Dependencies**: Core module only
- **Components**:
  - LoginUseCase, RegisterUseCase
  - CreateClassUseCase, UpdateClassUseCase
  - GenerateFlashcardsUseCase
  - CreateNoteUseCase, LinkNotesUseCase

### Layer 3: Presentation (ViewModels + Views)
- **Purpose**: UI logic and user interaction
- **Dependencies**: Core + Use Cases
- **Components**:
  - ViewModels (@MainActor, ObservableObject)
  - SwiftUI Views
  - Navigation coordinators

### Layer 4: Data (Repository Implementations)
- **Purpose**: Data persistence and retrieval
- **Dependencies**: Core protocols
- **Components**:
  - Mock implementations (current)
  - Real implementations (TODO: Firebase/CoreData)

## Module Descriptions

### Core Module
**Purpose**: Shared domain models and protocols

**Key Files**:
- `Models/User.swift` - User account model
- `Models/Class.swift` - Course/class with time slots
- `Models/Flashcard.swift` - Study flashcard
- `Models/Note.swift` - Note with linking capability
- `Protocols/RepositoryProtocols.swift` - Data access abstractions
- `Common/AppError.swift` - Application error types

**Testing**: See `Tests/CoreTests/`

### Authentication Module
**Purpose**: User authentication and account management

**Features**:
- Email/password login with validation
- User registration with college selection
- Session management
- Logout functionality

**Key Components**:
- `LoginUseCase` - Validates and performs login
- `RegisterUseCase` - Validates and creates account
- `LoginViewModel` - Login screen state
- `RegisterViewModel` - Registration screen state
- `LoginView` - Login UI
- `RegisterView` - Registration UI

**Testing**: See `Tests/AuthenticationTests/`

**Validation Rules**:
- Email: Must be valid format (regex validated)
- Password: Minimum 8 characters
- Name: Cannot be empty

### Class Management Module
**Purpose**: Manage student course schedule

**Features**:
- Add classes with course code and name
- Schedule classes with multiple time slots per week
- Time slot overlap detection
- Edit and delete classes
- View class list

**Key Components**:
- `CreateClassUseCase` - Creates class with validation
- `UpdateClassUseCase` - Updates existing class
- `DeleteClassUseCase` - Removes class
- `GetClassesUseCase` - Retrieves user's classes
- `ClassListViewModel` - Manages class list state
- `ClassFormViewModel` - Add/edit class form state

**Time Slot System**:
```swift
struct TimeSlot {
    let dayOfWeek: DayOfWeek // Monday-Sunday
    let startTime: Date
    let endTime: Date
}
```

**Validation Rules**:
- Class name cannot be empty
- Course code cannot be empty
- Time slots on same day cannot overlap

**Testing**: See `Tests/ClassManagementTests/`

### Flashcards Module
**Purpose**: Generate and study flashcards

**Features**:
- **Auto-generation** from notes using pattern matching
- Manual flashcard creation
- Review tracking
- Link flashcards to source notes

**Generation Algorithm**:
Extracts definitions from note content using patterns:
- "Term is definition" → Flashcard(front: "Term", back: "definition")
- "Term: definition" → Flashcard(front: "Term", back: "definition")

**Key Components**:
- `GenerateFlashcardsUseCase` - Creates flashcards from note
- `CreateFlashcardUseCase` - Manual flashcard creation
- `UpdateFlashcardUseCase` - Update review status
- `GetFlashcardsUseCase` - Retrieve flashcards for class

**Data Model**:
```swift
struct Flashcard {
    let classId: UUID
    let userId: UUID
    var front: String      // Question
    var back: String       // Answer
    var noteIds: [UUID]    // Source notes
    var lastReviewedAt: Date?
}
```

**Testing**: See `Tests/FlashcardsTests/`

### Notes Module
**Purpose**: Note-taking with intelligent linking

**Features**:
- Create and edit notes per class
- **Link related notes** together
- Tag notes for organization
- Search notes by content/tags
- View linked notes

**Key Components**:
- `CreateNoteUseCase` - Creates new note
- `UpdateNoteUseCase` - Updates existing note
- `LinkNotesUseCase` - Links two notes together
- `GetLinkedNotesUseCase` - Retrieves linked notes
- `GetNotesUseCase` - Gets all notes for a class

**Linking System**:
Notes can reference other notes, creating a knowledge graph:
```
Note A (Biology) → [Note B (Chemistry), Note C (Biology)]
Note B (Chemistry) → [Note D (Physics)]
```

**Data Model**:
```swift
struct Note {
    let classId: UUID
    let userId: UUID
    var title: String
    var content: String
    var linkedNoteIds: [UUID]  // Connected notes
    var tags: [String]         // Organization
}
```

**Testing**: See `Tests/NotesTests/`

## Testing Strategy

### Test-Driven Development (TDD)
All features developed following TDD:
1. Write failing test
2. Implement minimal code to pass
3. Refactor
4. Repeat

### Test Structure
```
Tests/
├── CoreTests/
│   └── Models/           # Model tests
├── AuthenticationTests/
│   └── UseCases/         # Business logic tests
├── ClassManagementTests/
│   └── UseCases/         # Class management tests
├── FlashcardsTests/
│   └── UseCases/         # Flashcard generation tests
└── NotesTests/
    └── UseCases/         # Note linking tests
```

### Mock Objects
Each test suite includes mock repository implementations:
- `MockAuthRepository` - Simulates auth operations
- `MockClassRepository` - Simulates class storage
- `MockFlashcardRepository` - Simulates flashcard storage
- `MockNoteRepository` - Simulates note storage

### Running Tests
```bash
# All tests
swift test

# Specific module
swift test --filter CoreTests
swift test --filter AuthenticationTests

# In Xcode
Cmd + U
```

## Data Flow

### Authentication Flow
```
User Input → LoginView
    ↓
LoginViewModel (validation)
    ↓
LoginUseCase (business rules)
    ↓
AuthRepository (data access)
    ↓
Result → ViewModel → View → User Feedback
```

### Class Creation Flow
```
User Input → ClassFormView
    ↓
ClassFormViewModel
    ↓
CreateClassUseCase (validation + overlap check)
    ↓
ClassRepository
    ↓
Success → Update UI → Show Class List
```

### Flashcard Generation Flow
```
Note Content → GenerateFlashcardsUseCase
    ↓
Pattern Matching Algorithm
    ↓
Extract Definitions
    ↓
Create Flashcard Models
    ↓
FlashcardRepository (batch create)
    ↓
Return Generated Flashcards
```

## API Reference

### Core Models

#### User
```swift
struct User {
    let id: UUID
    var email: String
    var name: String
    var collegeId: UUID?
    var createdAt: Date
    var updatedAt: Date
}
```

#### Class
```swift
struct Class {
    let id: UUID
    var userId: UUID
    var name: String
    var courseCode: String
    var schedule: [TimeSlot]
    var professor: String?
    var location: String?
}
```

#### Flashcard
```swift
struct Flashcard {
    let id: UUID
    var classId: UUID
    var userId: UUID
    var front: String
    var back: String
    var noteIds: [UUID]
    var lastReviewedAt: Date?
}
```

#### Note
```swift
struct Note {
    let id: UUID
    var classId: UUID
    var userId: UUID
    var title: String
    var content: String
    var linkedNoteIds: [UUID]
    var tags: [String]
}
```

### Repository Protocols

#### AuthRepositoryProtocol
```swift
protocol AuthRepositoryProtocol {
    func login(credentials: LoginCredentials) async throws -> AuthSession
    func register(data: RegistrationData) async throws -> AuthSession
    func logout() async throws
    func getCurrentSession() async -> AuthSession?
    func refreshToken() async throws -> AuthSession
}
```

#### ClassRepositoryProtocol
```swift
protocol ClassRepositoryProtocol {
    func getClasses(for userId: UUID) async throws -> [Class]
    func getClass(by id: UUID) async throws -> Class
    func createClass(_ classItem: Class) async throws -> Class
    func updateClass(_ classItem: Class) async throws -> Class
    func deleteClass(id: UUID) async throws
}
```

### Use Cases

#### LoginUseCase
```swift
func execute(credentials: LoginCredentials) async throws -> AuthSession
```
**Validation**:
- Email format check
- Non-empty email and password

#### CreateClassUseCase
```swift
func execute(classItem: Class) async throws -> Class
```
**Validation**:
- Non-empty name and course code
- No overlapping time slots on same day

#### GenerateFlashcardsUseCase
```swift
func execute(from note: Note, userId: UUID) async throws -> [Flashcard]
```
**Algorithm**:
1. Parse note content
2. Find definition patterns
3. Extract term/definition pairs
4. Create flashcard models
5. Save to repository

## Error Handling

All operations use `AppError` enum:

```swift
enum AppError: Error {
    case networkError(String)
    case authenticationFailed(String)
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case invalidData(String)
    case notFound(String)
    case unauthorized
    case serverError(String)
    case unknown(String)
}
```

Errors are caught in ViewModels and displayed to users.

## Future Enhancements

### Phase 1 (MVP Complete)
- ✅ Core domain models
- ✅ Authentication system
- ✅ Class management
- ✅ Flashcard generation
- ✅ Note taking with linking
- ✅ Unit tests

### Phase 2 (Data Persistence)
- [ ] Firebase integration
- [ ] CoreData local storage
- [ ] Offline support
- [ ] Data synchronization

### Phase 3 (Enhanced Features)
- [ ] Spaced repetition algorithm for flashcards
- [ ] Rich text editor for notes
- [ ] Image attachments
- [ ] Study statistics and analytics
- [ ] Collaboration features

### Phase 4 (Platform Expansion)
- [ ] macOS native app
- [ ] watchOS companion
- [ ] Web dashboard
- [ ] Export to PDF

## Contributing

When adding features:

1. **Write tests first** (TDD)
2. **Keep modules independent**
3. **Use dependency injection**
4. **Follow existing patterns**
5. **Document public APIs**
6. **Update ARCHITECTURE.md**

## License

MIT License - See LICENSE file
