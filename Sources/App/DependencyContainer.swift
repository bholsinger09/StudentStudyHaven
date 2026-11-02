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
        return MockUserRepositoryImpl()
    }()
    
    public lazy var classRepository: ClassRepositoryProtocol = {
        if useMockRepositories {
            return MockClassRepositoryImpl()
        } else {
            return CloudKitClassRepositoryImpl()
        }
    }()
    
    public lazy var flashcardRepository: FlashcardRepositoryProtocol = {
        if useMockRepositories {
            return MockFlashcardRepositoryImpl()
        } else {
            return CloudKitFlashcardRepositoryImpl()
        }
    }()
    
    public lazy var noteRepository: NoteRepositoryProtocol = {
        if useMockRepositories {
            return MockNoteRepositoryImpl()
        } else {
            return CloudKitNoteRepositoryImpl()
        }
    }()
    
    public lazy var studyGroupRepository: StudyGroupRepositoryProtocol = {
        if useMockRepositories {
            return MockStudyGroupRepositoryImpl()
        } else {
            return CloudKitStudyGroupRepositoryImpl()
        }
    }()
    
    public lazy var studySessionRepository: GroupStudySessionRepositoryProtocol = {
        if useMockRepositories {
            return MockStudySessionRepositoryImpl()
        } else {
            return CloudKitStudySessionRepositoryImpl()
        }
    }()
    
    public lazy var groupMessageRepository: GroupMessageRepositoryProtocol = {
        if useMockRepositories {
            return MockGroupMessageRepositoryImpl()
        } else {
            return CloudKitGroupMessageRepositoryImpl()
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
            assignmentRepository = MockAssignmentRepository()
        } else {
            authRepository = MockAuthRepositoryImpl()
            userRepository = MockUserRepositoryImpl()
            classRepository = CloudKitClassRepositoryImpl()
            flashcardRepository = CloudKitFlashcardRepositoryImpl()
            noteRepository = CloudKitNoteRepositoryImpl()
            studyGroupRepository = CloudKitStudyGroupRepositoryImpl()
            studySessionRepository = CloudKitStudySessionRepositoryImpl()
            groupMessageRepository = CloudKitGroupMessageRepositoryImpl()
            assignmentRepository = CloudKitAssignmentRepositoryImpl()
        }
    }
}
