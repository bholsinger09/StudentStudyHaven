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
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    // Dependencies
    let authRepository: AuthRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let classRepository: ClassRepositoryProtocol
    let flashcardRepository: FlashcardRepositoryProtocol
    let noteRepository: NoteRepositoryProtocol
    let studyGroupRepository: StudyGroupRepositoryProtocol
    let studySessionRepository: GroupStudySessionRepositoryProtocol
    let groupMessageRepository: GroupMessageRepositoryProtocol

    init() {
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

    func login(user: User) {
        currentUser = user
        isAuthenticated = true
    }

    func logout() async {
        try? await authRepository.logout()
        currentUser = nil
        isAuthenticated = false
    }
}
