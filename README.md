# StudentStudyHaven

A comprehensive iOS and macOS application built with SwiftUI to help college students manage their academic life.

## Features

- **College Selection**: Choose and register with your enrolled college
- **Authentication**: Secure login and registration system
- **Class Management**: Add and organize classes with time slots
- **Smart Flashcards**: Generate flashcards quickly from your notes
- **Note Taking**: Comprehensive note-taking system with linked notes
- **Cross-platform**: Works on both iOS and macOS

## Architecture

This app follows clean architecture principles with:

- **MVVM Pattern**: Model-View-ViewModel for presentation layer
- **Use Cases**: Business logic encapsulated in use cases
- **Repository Pattern**: Abstract data access layer
- **Modular Design**: Split into Swift Packages for better organization and testability

### Modules

- **Core**: Shared models, protocols, and utilities
- **Authentication**: Login and registration features
- **ClassManagement**: Class scheduling and management
- **Flashcards**: Flashcard generation and study features
- **Notes**: Note-taking with linking capabilities

## Requirements

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Open `StudentStudyHaven.xcodeproj` or the package in Xcode
3. Build and run the project

## Testing

The app is built with Test-Driven Development (TDD) principles. Run tests using:
- Xcode: `Cmd + U`
- Command line: `swift test`

## License

MIT License
