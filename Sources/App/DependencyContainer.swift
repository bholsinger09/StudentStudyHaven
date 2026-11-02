import Authentication
import ClassManagement
import Core
import Flashcards
import GradeTracking
import iCloudIntegration
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
    
    // Assignment repository (uses CloudKit via iCloudIntegration)
    public lazy var assignmentRepository: AssignmentRepositoryProtocol = {
        if useMockRepositories {
            return MockAssignmentRepository()
        } else {
            return CloudKitAssignmentRepositoryImpl()
        }
    }()
    
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
            return FirestoreClassRepositoryImpl()
        }
    }()
    
    public lazy var flashcardRepository: FlashcardRepositoryProtocol = {
        if useMockRepositories {
            return MockFlashcardRepositoryImpl()
        } else {
            return FirestoreFlashcardRepositoryImpl()
        }
    }()
    
    public lazy var noteRepository: NoteRepositoryProtocol = {
        if useMockRepositories {
            return MockNoteRepositoryImpl()
        } else {
            return FirestoreNoteRepositoryImpl()
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
            return FirestoreGroupStudySessionRepositoryImpl()
        }
    }()
    
    public lazy var groupMessageRepository: GroupMessageRepositoryProtocol = {
        if useMockRepositories {
            return MockGroupMessageRepositoryImpl()
        } else {
            return FirestoreGroupMessageRepositoryImpl()
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
            userRepository = FirestoreUserRepositoryImpl()
            classRepository = FirestoreClassRepositoryImpl()
            flashcardRepository = FirestoreFlashcardRepositoryImpl()
            noteRepository = FirestoreNoteRepositoryImpl()
            studyGroupRepository = FirestoreStudyGroupRepositoryImpl()
            studySessionRepository = FirestoreGroupStudySessionRepositoryImpl()
            groupMessageRepository = FirestoreGroupMessageRepositoryImpl()
        }
    }
}
