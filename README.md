# 🎓 StudentStudyHaven

> A comprehensive iOS and macOS application built with SwiftUI to help college students manage their academic life.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016%2B%20%7C%20macOS%2013%2B-blue.svg)](https://developer.apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%7C%20MVVM-green.svg)](ARCHITECTURE.md)
[![Tests](https://img.shields.io/badge/Tests-35%2B%20passing-brightgreen.svg)](Tests/)

---

## ✨ Features

### 🔥 **NEW: Firebase Backend Integration**
- **Real user authentication** with Firebase Auth
- **Persistent data storage** with Firestore
- **Offline support** with automatic sync
- **Real-time updates** across devices
- Toggle between mock and live data for testing

### 🔐 Authentication System
- **Secure Login & Registration** with email validation
- College selection during registration
- Session management with token refresh
- Firebase Auth integration

### 📚 Class Management
- Add and organize classes with course codes
- **Smart Time Slots** with automatic overlap detection
- Professor and location tracking
- Weekly schedule view
- Persistent storage in Firestore

### 🎴 Smart Flashcards
- **Auto-generate flashcards** from your notes using AI-like pattern matching
- Manual flashcard creation
- Review tracking with last-reviewed timestamps
- Link flashcards to source notes
- Cloud sync for study sessions

### 📝 Intelligent Note Taking
- Create and organize notes per class
- **Link related notes** together to build a knowledge graph
- Tag system for organization
- Full-text search across all notes
- Real-time sync for collaborative note-taking

### 🎯 Cross-platform
- iOS 16+ support
- macOS 13+ support
- Shared business logic across platforms

## 🏗️ Architecture

Built with **Clean Architecture** principles and modern Swift practices:

```
┌─────────────────────────────────────────────┐
│            Presentation Layer               │
│     (SwiftUI Views + ViewModels)            │
├─────────────────────────────────────────────┤
│          Business Logic Layer               │
│            (Use Cases)                      │
├─────────────────────────────────────────────┤
│            Domain Layer                     │
│    (Models + Repository Protocols)          │
├─────────────────────────────────────────────┤
│            Data Layer                       │
│      (Repository Implementations)           │
└─────────────────────────────────────────────┘
```

### Design Patterns
- ✅ **MVVM**: Model-View-ViewModel for presentation layer
- ✅ **Use Cases**: Single-responsibility business logic
- ✅ **Repository Pattern**: Abstract data access layer
- ✅ **Dependency Injection**: Protocol-based dependencies
- ✅ **Clean Architecture**: Clear layer separation

### 📦 Modular Packages

| Module | Purpose | Dependencies | Files |
|--------|---------|--------------|-------|
| **Core** | Domain models & protocols | None | 7 |
| **Authentication** | Login & registration | Core | 8 |
| **ClassManagement** | Course scheduling | Core | 7 |
| **Flashcards** | Flashcard generation | Core | 5 |
| **Notes** | Note-taking & linking | Core | 6 |

**Total**: 46 Swift files, 2,500+ lines of code

## 🚀 Quick Start

### Prerequisites
- **Xcode** 15.0+ 
- **Swift** 5.9+
- **iOS** 16.0+ or **macOS** 13.0+
- **Firebase Account** (free)

### Installation

```bash
# Clone the repository
git clone https://github.com/bholsinger09/StudentStudyHaven.git
cd StudentStudyHaven

# Set up Firebase (required for backend features)
# Follow instructions in FIREBASE_SETUP.md (5 minutes)

# Open in Xcode
open Package.swift

# Or run tests from command line
swift test
```

### Running the App

1. **Set up Firebase** (one-time, 5 minutes) - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
2. Open `Package.swift` in Xcode
3. Choose your target (iOS Simulator or macOS)
4. Press `Cmd + R` to run
5. Register a new account to start using the app!

**See [QUICKSTART.md](QUICKSTART.md) for detailed setup instructions.**

## 🧪 Testing

Built with **Test-Driven Development (TDD)** from the ground up:

```bash
# Run all tests
swift test

# Run specific module tests
swift test --filter AuthenticationTests
swift test --filter ClassManagementTests
swift test --filter FlashcardsTests
swift test --filter NotesTests
```

**Test Coverage**: 35+ unit tests covering all use cases, edge cases, and business logic.

### Test Structure
- ✅ **Use Case Tests**: Business logic validation
- ✅ **Model Tests**: Data structure correctness
- ✅ **Mock Repositories**: Fast, isolated testing
- ✅ **Edge Cases**: Error handling and validation

## 📚 Documentation

Comprehensive documentation included:

### Getting Started
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Firebase setup guide (5 minutes) ⭐
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[SETUP.md](SETUP.md)** - Detailed setup and build instructions

### Technical Documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical deep dive (500+ lines)
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview
- **[PHASE_1_COMPLETE.md](PHASE_1_COMPLETE.md)** - Phase 1: UI Implementation
- **[PHASE_2_COMPLETE.md](PHASE_2_COMPLETE.md)** - Phase 2: Firebase Integration ⭐

## License

MIT License
