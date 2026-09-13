//
//  AppState.swift
//  StudentStudyHaven
//
//  Created by Ben H on 11/24/25.
//

import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import StudyGroups
import SwiftUI

/// Application state management
@MainActor
public class AppState: ObservableObject {
    @Published public var currentUser: User?
    @Published public var isAuthenticated: Bool = false

    // Dependencies
    public let authRepository: AuthRepositoryProtocol
    public let userRepository: UserRepositoryProtocol
    public let classRepository: ClassRepositoryProtocol
    public let flashcardRepository: FlashcardRepositoryProtocol
    public let noteRepository: NoteRepositoryProtocol
    public let studyGroupRepository: StudyGroupRepositoryProtocol
    public let studySessionRepository: GroupStudySessionRepositoryProtocol
    public let groupMessageRepository: GroupMessageRepositoryProtocol

    public init() {
        // Initialize with Firebase repositories for Study Groups, mocks for others
        let container = DependencyContainer.shared
        self.authRepository = container.authRepository
        self.userRepository = container.userRepository
        self.classRepository = container.classRepository
        self.flashcardRepository = container.flashcardRepository
        self.noteRepository = container.noteRepository
        self.studyGroupRepository = container.studyGroupRepository
        self.studySessionRepository = container.studySessionRepository
        self.groupMessageRepository = container.groupMessageRepository

        Task {
            await checkAuthStatus()
        }
    }

    func checkAuthStatus() async {
        if let session = await authRepository.getCurrentSession() {
            currentUser = session.user
            isAuthenticated = true
        }
    }

    public func login(user: User) {
        currentUser = user
        isAuthenticated = true
    }

    public func logout() async {
        try? await authRepository.logout()
        currentUser = nil
        isAuthenticated = false
    }
}
