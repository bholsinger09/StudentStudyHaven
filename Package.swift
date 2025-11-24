// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StudentStudyHaven",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "StudentStudyHaven",
            targets: ["App"]),
        .library(
            name: "Core",
            targets: ["Core"]),
        .library(
            name: "Authentication",
            targets: ["Authentication"]),
        .library(
            name: "ClassManagement",
            targets: ["ClassManagement"]),
        .library(
            name: "Flashcards",
            targets: ["Flashcards"]),
        .library(
            name: "Notes",
            targets: ["Notes"]),
    ],
    dependencies: [],
    targets: [
        // MARK: - App Target
        .executableTarget(
            name: "App",
            dependencies: ["Core", "Authentication", "ClassManagement", "Flashcards", "Notes"],
            path: "Sources/App"),
        
        // MARK: - Core Module
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"),
        
        // MARK: - Authentication Module
        .target(
            name: "Authentication",
            dependencies: ["Core"],
            path: "Sources/Authentication"),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication", "Core"],
            path: "Tests/AuthenticationTests"),
        
        // MARK: - Class Management Module
        .target(
            name: "ClassManagement",
            dependencies: ["Core"],
            path: "Sources/ClassManagement"),
        .testTarget(
            name: "ClassManagementTests",
            dependencies: ["ClassManagement", "Core"],
            path: "Tests/ClassManagementTests"),
        
        // MARK: - Flashcards Module
        .target(
            name: "Flashcards",
            dependencies: ["Core"],
            path: "Sources/Flashcards"),
        .testTarget(
            name: "FlashcardsTests",
            dependencies: ["Flashcards", "Core"],
            path: "Tests/FlashcardsTests"),
        
        // MARK: - Notes Module
        .target(
            name: "Notes",
            dependencies: ["Core"],
            path: "Sources/Notes"),
        .testTarget(
            name: "NotesTests",
            dependencies: ["Notes", "Core"],
            path: "Tests/NotesTests"),
    ]
)
