# Student Study Haven - Project Setup Guide

## Prerequisites
- Xcode 15.0 or later
- macOS 13.0 or later
- iOS 16.0 or later (for iOS targets)

## Project Structure

The project follows a modular architecture using Swift Package Manager:

```
StudentStudyHaven/
├── Package.swift                  # Main package definition
├── App/                          # Main iOS/macOS app target
│   ├── StudentStudyHavenApp.swift
│   ├── Views/
│   └── Info.plist
├── Sources/
│   ├── Core/                     # Core domain models and protocols
│   │   ├── Models/
│   │   ├── Protocols/
│   │   └── Common/
│   ├── Authentication/           # Authentication module
│   │   ├── Models/
│   │   ├── UseCases/
│   │   ├── Presentation/
│   │   ├── Protocols/
│   │   └── Data/
│   ├── ClassManagement/          # Class management module
│   │   ├── UseCases/
│   │   ├── Presentation/
│   │   └── Data/
│   ├── Flashcards/              # Flashcard generation module
│   │   ├── UseCases/
│   │   └── Data/
│   └── Notes/                    # Note-taking module
│       ├── UseCases/
│       └── Data/
└── Tests/                        # Unit tests
    ├── CoreTests/
    ├── AuthenticationTests/
    ├── ClassManagementTests/
    ├── FlashcardsTests/
    └── NotesTests/
```

## Building the Project

### Option 1: Using Xcode with Swift Package

1. Open Terminal and navigate to the project directory:
   ```bash
   cd /Users/benh/Documents/StudentStudyHaven
   ```

2. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

3. Once Xcode opens, you can build and run the tests:
   - Press `Cmd + B` to build
   - Press `Cmd + U` to run tests

### Option 2: Creating an Xcode Project

To create a proper iOS/macOS app project:

1. Open Xcode
2. Create a new project: File → New → Project
3. Select "iOS" → "App"
4. Configure:
   - Product Name: StudentStudyHaven
   - Team: Your team
   - Organization Identifier: com.yourname
   - Interface: SwiftUI
   - Language: Swift
5. Save in: `/Users/benh/Documents/StudentStudyHaven`
6. Add the Swift Packages as local dependencies

### Option 3: Command Line Build

Run tests from command line:
```bash
swift test
```

Build the package:
```bash
swift build
```

## Running Tests

The project includes comprehensive unit tests following TDD principles:

### Run all tests:
```bash
swift test
```

### Run specific test targets:
```bash
swift test --filter CoreTests
swift test --filter AuthenticationTests
swift test --filter ClassManagementTests
```

### In Xcode:
- Press `Cmd + U` to run all tests
- Click the diamond next to individual test methods to run specific tests

## Architecture Overview

### MVVM + Use Cases + Repository Pattern

1. **Models (Domain Layer)**
   - Located in `Sources/Core/Models/`
   - Pure Swift types representing business entities
   - No dependencies on frameworks

2. **Use Cases (Business Logic Layer)**
   - Located in each module's `UseCases/` folder
   - Encapsulate business rules and application logic
   - Accept repository protocols as dependencies

3. **Repositories (Data Layer)**
   - Protocols in `Core/Protocols/`
   - Mock implementations in each module's `Data/` folder
   - Can be replaced with real implementations (Firebase, CoreData, etc.)

4. **ViewModels (Presentation Layer)**
   - Located in each module's `Presentation/ViewModels/`
   - ObservableObject classes for SwiftUI views
   - Use @Published properties for reactive updates

5. **Views (UI Layer)**
   - Located in each module's `Presentation/Views/`
   - SwiftUI views
   - Observe ViewModels

## Features

### Implemented:

✅ **Core Module**
- User, College, Class, Flashcard, Note models
- Repository protocols
- Common error types

✅ **Authentication Module**
- Login use case with validation
- Registration use case with validation
- Logout functionality
- Login and Register views with ViewModels
- Mock repository implementation

✅ **Class Management Module**
- Create, read, update, delete classes
- Time slot management with overlap validation
- Class list and form ViewModels
- Mock repository implementation

✅ **Flashcards Module**
- Generate flashcards from notes automatically
- Manual flashcard creation
- Flashcard review system
- Mock repository implementation

✅ **Notes Module**
- Create and update notes
- Link notes together
- Get linked notes
- Mock repository implementation

✅ **Testing**
- Unit tests for all use cases
- Mock repositories for testing
- Model tests

### To Be Implemented:

- Complete UI views for all modules
- College selection feature
- Real data persistence (CoreData/Firebase)
- macOS target
- Advanced flashcard algorithms (spaced repetition)
- Note search functionality UI
- Rich text editor for notes
- File attachments

## Development Workflow

1. **Write Tests First (TDD)**
   - Create test file in appropriate Tests folder
   - Write failing test
   - Implement feature
   - Ensure test passes

2. **Create Use Cases**
   - Define in module's UseCases folder
   - Accept repository protocols
   - Implement business logic with validation

3. **Create ViewModels**
   - Use @MainActor for thread safety
   - Accept use cases as dependencies
   - Use @Published for reactive properties

4. **Create Views**
   - SwiftUI views observing ViewModels
   - Handle user interactions
   - Display data from ViewModels

## Dependencies

The project is built with:
- **Swift 5.9+**
- **SwiftUI** - UI framework
- **Combine** - Reactive programming
- **XCTest** - Testing framework

No external dependencies required!

## Next Steps

1. Create an Xcode project (see Option 2 above)
2. Add the local packages to your project
3. Implement remaining UI views
4. Replace mock repositories with real implementations
5. Add data persistence
6. Deploy to TestFlight

## Contributing

When adding new features:
1. Create tests first
2. Keep modules independent
3. Use dependency injection
4. Follow existing patterns
5. Update this README

## License

MIT License - See LICENSE file for details
