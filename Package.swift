// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StudentStudyHaven",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
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
    dependencies: [
        // Firebase temporarily disabled - uncomment when ready to use real backend
        // .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0"),
    ],
    targets: [
        // MARK: - App Target
        .executableTarget(
            name: "App",
            dependencies: [
                "Core", 
                "Authentication", 
                "ClassManagement", 
                "Flashcards", 
                "Notes",
                // Firebase temporarily disabled
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/App"),

        // MARK: - Core Module
        .target(
            name: "Core",
            dependencies: [
                // Firebase temporarily disabled
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Core"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"),

        // MARK: - Authentication Module
        .target(
            name: "Authentication",
            dependencies: [
                "Core",
                // Firebase temporarily disabled
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Authentication"),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication", "Core"],
            path: "Tests/AuthenticationTests"),

        // MARK: - Class Management Module
        .target(
            name: "ClassManagement",
            dependencies: [
                "Core",
                // Firebase temporarily disabled
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/ClassManagement"),
        .testTarget(
            name: "ClassManagementTests",
            dependencies: ["ClassManagement", "Core"],
            path: "Tests/ClassManagementTests"),

        // MARK: - Flashcards Module
        .target(
            name: "Flashcards",
            dependencies: [
                "Core",
                // Firebase temporarily disabled
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Flashcards"),
        .testTarget(
            name: "FlashcardsTests",
            dependencies: ["Flashcards", "Core"],
            path: "Tests/FlashcardsTests"),

        // MARK: - Notes Module
        .target(
            name: "Notes",
            dependencies: [
                "Core",
                // Firebase temporarily disabled
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ],
            path: "Sources/Notes"),
        .testTarget(
            name: "NotesTests",
            dependencies: ["Notes", "Core"],
            path: "Tests/NotesTests"),
    ]
)
