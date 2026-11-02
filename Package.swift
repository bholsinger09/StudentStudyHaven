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
        .library(
            name: "App",
            targets: ["App"]),
        .library(
            name: "Core",
            targets: ["Core"]),
        .library(
            name: "iCloudIntegration",
            targets: ["iCloudIntegration"]),
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
        .library(
            name: "StudyGroups",
            targets: ["StudyGroups"]),
        .library(
            name: "GradeTracking",
            targets: ["GradeTracking"]),
    ],
    dependencies: [
        // CloudKit is built-in to iOS - no external dependency needed!
    ],
    targets: [
        // MARK: - App Library Target
        .target(
            name: "App",
            dependencies: [
                "Core",
                "iCloudIntegration",
                "Authentication",
                "ClassManagement",
                "Flashcards",
                "Notes",
                "StudyGroups",
                "GradeTracking",
            ],
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

        // MARK: - iCloud Integration Module (CloudKit)
        .target(
            name: "iCloudIntegration",
            dependencies: [
                "Core",
            ],
            path: "Sources/iCloudIntegration"),

        // MARK: - Authentication Module
        .target(
            name: "Authentication",
            dependencies: [
                "Core",
                "iCloudIntegration",
            ],
            path: "Sources/Authentication",
            linkerSettings: [
                .linkedFramework("AuthenticationServices", .when(platforms: [.iOS, .macOS])),
            ]),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication", "Core"],
            path: "Tests/AuthenticationTests"),

        // MARK: - Class Management Module
        .target(
            name: "ClassManagement",
            dependencies: [
                "Core",
                "GradeTracking",
                "iCloudIntegration",
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
                "iCloudIntegration",
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
                "iCloudIntegration",
            ],
            path: "Sources/Notes"),
        .testTarget(
            name: "NotesTests",
            dependencies: ["Notes", "Core"],
            path: "Tests/NotesTests"),

        // MARK: - Study Groups Module
        .target(
            name: "StudyGroups",
            dependencies: [
                "Core",
                "iCloudIntegration",
            ],
            path: "Sources/StudyGroups"),
        .testTarget(
            name: "StudyGroupsTests",
            dependencies: ["StudyGroups", "Core"],
            path: "Tests/StudyGroupsTests"),

        // MARK: - Grade Tracking Module
        .target(
            name: "GradeTracking",
            dependencies: [
                "Core",
                "iCloudIntegration",
            ],
            path: "Sources/GradeTracking"),
        .testTarget(
            name: "GradeTrackingTests",
            dependencies: ["GradeTracking", "Core"],
            path: "Tests/GradeTrackingTests"),
    ]
)
