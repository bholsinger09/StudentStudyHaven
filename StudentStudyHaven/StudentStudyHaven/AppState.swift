//
//  AppState.swift
//  StudentStudyHaven
//
//  Created by Ben H on 11/24/25.
//

import SwiftUI
import Core
import Authentication
import ClassManagement
import Flashcards
import Notes

/// Application state management
@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    // Dependencies
    let authRepository: AuthRepositoryProtocol
    let classRepository: ClassRepositoryProtocol
    let flashcardRepository: FlashcardRepositoryProtocol
    let noteRepository: NoteRepositoryProtocol
    
    init() {
        // Initialize with mock repositories (replace with real implementations)
        self.authRepository = MockAuthRepositoryImpl()
        self.classRepository = MockClassRepositoryImpl()
        self.flashcardRepository = MockFlashcardRepositoryImpl()
        self.noteRepository = MockNoteRepositoryImpl()
        
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
