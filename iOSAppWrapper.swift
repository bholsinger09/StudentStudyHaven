import SwiftUI
import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import StudyGroups

@main
struct StudentStudyHavenApp: App {
    @StateObject private var appState = AppState()

    init() {
        DependencyContainer.shared.useMockRepositories = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

/// Application state management
@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    let authRepository: AuthRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let classRepository: ClassRepositoryProtocol
    let flashcardRepository: FlashcardRepositoryProtocol
    let noteRepository: NoteRepositoryProtocol
    let studyGroupRepository: StudyGroupRepositoryProtocol
    let studySessionRepository: GroupStudySessionRepositoryProtocol
    let groupMessageRepository: GroupMessageRepositoryProtocol

    init() {
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
