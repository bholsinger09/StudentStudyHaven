# StudentStudyHaven - Quick Start Guide

## 🎓 Welcome to StudentStudyHaven!

A comprehensive iOS/macOS app for college students built with SwiftUI, following clean architecture principles and TDD.

## 🚀 Quick Setup (5 minutes)

### Option 1: Open in Xcode (Recommended)
```bash
cd /Users/benh/Documents/StudentStudyHaven
open Package.swift
```
Then press `Cmd + B` to build and `Cmd + U` to run tests!

### Option 2: Command Line
```bash
cd /Users/benh/Documents/StudentStudyHaven
swift test    # Run all tests
swift build   # Build the package
```

## 📁 Project Overview

```
StudentStudyHaven/
├── 📦 Sources/
│   ├── Core/                 # Domain models & protocols
│   ├── Authentication/       # Login & Registration
│   ├── ClassManagement/      # Course scheduling
│   ├── Flashcards/          # Auto-generate flashcards
│   └── Notes/               # Note-taking with links
├── 🧪 Tests/                # Comprehensive unit tests
├── 📱 App/                  # Main iOS/macOS app
└── 📚 Documentation/
    ├── README.md           # Project overview
    ├── SETUP.md           # Detailed setup guide
    └── ARCHITECTURE.md    # Technical documentation
```

## ✨ Features Implemented

### ✅ Authentication
- Email/password login with validation
- User registration with college selection
- Session management
- **Test Coverage**: Login/Register use cases

### ✅ Class Management
- Add classes with course codes
- Multiple time slots per class
- Automatic overlap detection
- Edit and delete classes
- **Test Coverage**: Create/Update/Delete use cases

### ✅ Flashcard Generation
- **Auto-generate** flashcards from notes!
- Pattern matching: "Term is definition" → Flashcard
- Manual flashcard creation
- Review tracking
- **Test Coverage**: Generation algorithm tests

### ✅ Note Taking
- Create and edit notes per class
- **Link related notes** together
- Tag organization
- Search functionality
- **Test Coverage**: Note linking tests

## 🧪 Testing

### Run All Tests
```bash
swift test
```

### Run Specific Module
```bash
swift test --filter CoreTests
swift test --filter AuthenticationTests
swift test --filter ClassManagementTests
swift test --filter FlashcardsTests
swift test --filter NotesTests
```

### Test Coverage
- ✅ 35+ unit tests
- ✅ All use cases tested
- ✅ Mock repositories for isolation
- ✅ Edge cases covered

## 🏗️ Architecture

**Pattern**: MVVM + Use Cases + Repository

```
View → ViewModel → UseCase → Repository → Data
  ↑                                          ↓
  └──────────── Result ←────────────────────┘
```

**Benefits**:
- ✅ Testable (each layer tested independently)
- ✅ Maintainable (clear separation of concerns)
- ✅ Modular (packages are independent)
- ✅ Scalable (easy to add new features)

## 📖 Key Files to Explore

### Start Here:
1. **README.md** - Project overview
2. **SETUP.md** - Detailed setup instructions
3. **ARCHITECTURE.md** - Technical deep dive

### Core Models:
- `Sources/Core/Models/User.swift`
- `Sources/Core/Models/Class.swift`
- `Sources/Core/Models/Flashcard.swift`
- `Sources/Core/Models/Note.swift`

### Example Use Case:
- `Sources/Authentication/UseCases/LoginUseCase.swift`
- `Tests/AuthenticationTests/UseCases/LoginUseCaseTests.swift`

### Example ViewModel:
- `Sources/Authentication/Presentation/ViewModels/LoginViewModel.swift`

### Example View:
- `Sources/Authentication/Presentation/Views/LoginView.swift`

## 🔧 Development Workflow

### Adding a New Feature (TDD)

1. **Write Test First**
```bash
# Create test file
Tests/YourModuleTests/UseCases/YourFeatureUseCaseTests.swift
```

2. **Write Failing Test**
```swift
func testYourFeature() async throws {
    // Given
    let input = ...
    
    // When
    let result = try await useCase.execute(input)
    
    // Then
    XCTAssertEqual(result, expected)
}
```

3. **Implement Feature**
```swift
// Sources/YourModule/UseCases/YourFeatureUseCase.swift
public final class YourFeatureUseCase {
    public func execute(...) async throws -> Result {
        // Implementation
    }
}
```

4. **Run Test**
```bash
swift test --filter YourModuleTests
```

5. **Create ViewModel** (if UI needed)
6. **Create View** (if UI needed)

## 📱 Creating iOS App

The Swift Package is ready! To create an actual iOS app:

1. Open Xcode
2. File → New → Project
3. Choose "iOS App"
4. Product Name: **StudentStudyHaven**
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Save to: `/Users/benh/Documents/StudentStudyHaven`
8. Add local packages (Core, Authentication, etc.)

See **SETUP.md** for detailed instructions.

## 🎯 Next Steps

### Phase 1: Complete UI (Your Next Task!)
- [ ] Add remaining SwiftUI views
- [ ] Implement navigation
- [ ] Create college selection screen
- [ ] Build flashcard study interface
- [ ] Add note editor with rich text

### Phase 2: Data Persistence
- [ ] Add Firebase/CoreData
- [ ] Implement real repositories
- [ ] Add offline support
- [ ] Cloud synchronization

### Phase 3: Advanced Features
- [ ] Spaced repetition for flashcards
- [ ] Note attachments (images, PDFs)
- [ ] Study statistics
- [ ] Collaboration features

### Phase 4: Platform Expansion
- [ ] macOS app
- [ ] watchOS companion
- [ ] Web dashboard

## 🤝 Contributing

The codebase follows strict patterns:

1. **TDD**: Write tests first
2. **Clean Architecture**: Respect layer boundaries
3. **MVVM**: Keep ViewModels testable
4. **Dependency Injection**: Use protocols
5. **Documentation**: Comment public APIs

## 📚 Learning Resources

### Understanding the Architecture:
- **Use Cases**: Business logic in `Sources/*/UseCases/`
- **ViewModels**: Presentation logic in `Sources/*/Presentation/ViewModels/`
- **Views**: UI in `Sources/*/Presentation/Views/`
- **Repositories**: Data access via protocols in `Sources/Core/Protocols/`

### Testing Examples:
- Look at `Tests/AuthenticationTests/UseCases/LoginUseCaseTests.swift`
- See mock implementations in test files
- Notice the Given-When-Then pattern

### SwiftUI Examples:
- Check `Sources/Authentication/Presentation/Views/LoginView.swift`
- See how ViewModels connect to Views
- Observe @StateObject and @Published usage

## 🐛 Troubleshooting

### "No such module 'Core'"
This is normal for the Swift Package. The modules will resolve when:
- Building with `swift build`
- Opening in Xcode
- Running tests with `swift test`

### Can't run on iOS Simulator
You need to create an Xcode project first (see SETUP.md). The Package.swift defines libraries, not an executable app.

### Tests failing
```bash
swift test --verbose  # See detailed output
```

## 💡 Pro Tips

1. **Use Xcode's Test Navigator** (`Cmd + 6`) to see all tests
2. **Run individual tests** by clicking the diamond next to test methods
3. **Use breakpoints** in ViewModels to debug state changes
4. **Check ARCHITECTURE.md** for detailed flow diagrams
5. **Mock repositories** make tests fast and reliable

## 📞 Support

- **GitHub**: https://github.com/bholsinger09/StudentStudyHaven
- **Documentation**: See `SETUP.md` and `ARCHITECTURE.md`
- **Tests**: Run `swift test` to verify everything works

## 🎉 You're Ready!

The foundation is built with:
✅ Clean architecture
✅ Modular design
✅ Comprehensive tests
✅ Mock implementations
✅ SwiftUI examples

Now it's time to build the complete UI and make it shine! 🚀

---

**Remember**: This is a TDD project. Write tests first, then implement features. The architecture is designed to make this easy!
