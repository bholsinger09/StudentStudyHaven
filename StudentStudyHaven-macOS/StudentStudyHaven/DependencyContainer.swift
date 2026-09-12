import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import StudyGroups
import Foundation

/// Dependency injection container for managing repository instances
/// Provides a central place to configure and access repositories throughout the app
@MainActor
public class DependencyContainer {
    public static let shared = DependencyContainer()
    
    // MARK: - Configuration
    
    /// Set to true to use mock repositories for testing/development
    /// Set to false to use Firebase repositories for production
    public var useMockRepositories: Bool = false
    
    // MARK: - Repository Instances
    
    public lazy var authRepository: AuthRepositoryProtocol = {
        if useMockRepositories {
            return MockAuthRepositoryImpl()
        } else {
            return MockAuthRepositoryImpl() // FirebaseAuthRepositoryImpl() when ready
        }
    }()
    
    public lazy var userRepository: UserRepositoryProtocol = {
        if useMockRepositories {
            return MockUserRepositoryImpl()
        } else {
            return FirebaseUserRepositoryImpl()
        }
    }()
    
    public lazy var classRepository: ClassRepositoryProtocol = {
        if useMockRepositories {
            return MockClassRepositoryImpl()
        } else {
            return MockClassRepositoryImpl() // FirebaseClassRepositoryImpl() when ready
        }
    }()
    
    public lazy var flashcardRepository: FlashcardRepositoryProtocol = {
        if useMockRepositories {
            return MockFlashcardRepositoryImpl()
        } else {
            return MockFlashcardRepositoryImpl() // FirebaseFlashcardRepositoryImpl() when ready
        }
    }()
    
    public lazy var noteRepository: NoteRepositoryProtocol = {
        if useMockRepositories {
            return MockNoteRepositoryImpl()
        } else {
            return MockNoteRepositoryImpl() // FirebaseNoteRepositoryImpl() when ready
        }
    }()
    
    public lazy var studyGroupRepository: StudyGroupRepositoryProtocol = {
        if useMockRepositories {
            return MockStudyGroupRepositoryImpl()
        } else {
            return FirebaseStudyGroupRepositoryImpl()
        }
    }()
    
    public lazy var studySessionRepository: GroupStudySessionRepositoryProtocol = {
        if useMockRepositories {
            return MockStudySessionRepositoryImpl()
        } else {
            return FirebaseStudySessionRepositoryImpl()
        }
    }()
    
    public lazy var groupMessageRepository: GroupMessageRepositoryProtocol = {
        if useMockRepositories {
            return MockGroupMessageRepositoryImpl()
        } else {
            return FirebaseGroupMessageRepositoryImpl()
        }
    }()
    
    // MARK: - Initialization
    
    private init() {}
    
    /// Reset all repository instances (useful for testing or switching modes)
    public func reset() {
        if useMockRepositories {
            authRepository = MockAuthRepositoryImpl()
            userRepository = MockUserRepositoryImpl()
            classRepository = MockClassRepositoryImpl()
            flashcardRepository = MockFlashcardRepositoryImpl()
            noteRepository = MockNoteRepositoryImpl()
            studyGroupRepository = MockStudyGroupRepositoryImpl()
            studySessionRepository = MockStudySessionRepositoryImpl()
            groupMessageRepository = MockGroupMessageRepositoryImpl()
        } else {
            authRepository = MockAuthRepositoryImpl() // FirebaseAuthRepositoryImpl()
            userRepository = FirebaseUserRepositoryImpl()
            classRepository = MockClassRepositoryImpl() // FirebaseClassRepositoryImpl()
            flashcardRepository = MockFlashcardRepositoryImpl() // FirebaseFlashcardRepositoryImpl()
            noteRepository = MockNoteRepositoryImpl() // FirebaseNoteRepositoryImpl()
            studyGroupRepository = FirebaseStudyGroupRepositoryImpl()
            studySessionRepository = FirebaseStudySessionRepositoryImpl()
            groupMessageRepository = FirebaseGroupMessageRepositoryImpl()
        }
    }
}
