import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
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
        // Firebase temporarily disabled - always use mocks
        return MockAuthRepositoryImpl()
        // if useMockRepositories {
        //     return MockAuthRepositoryImpl()
        // } else {
        //     return FirebaseAuthRepositoryImpl()
        // }
    }()
    
    public lazy var classRepository: ClassRepositoryProtocol = {
        // Firebase temporarily disabled - always use mocks
        return MockClassRepositoryImpl()
        // if useMockRepositories {
        //     return MockClassRepositoryImpl()
        // } else {
        //     return FirebaseClassRepositoryImpl()
        // }
    }()
    
    public lazy var flashcardRepository: FlashcardRepositoryProtocol = {
        // Firebase temporarily disabled - always use mocks
        return MockFlashcardRepositoryImpl()
        // if useMockRepositories {
        //     return MockFlashcardRepositoryImpl()
        // } else {
        //     return FirebaseFlashcardRepositoryImpl()
        // }
    }()
    
    public lazy var noteRepository: NoteRepositoryProtocol = {
        // Firebase temporarily disabled - always use mocks
        return MockNoteRepositoryImpl()
        // if useMockRepositories {
        //     return MockNoteRepositoryImpl()
        // } else {
        //     return FirebaseNoteRepositoryImpl()
        // }
    }()
    
    // MARK: - Initialization
    
    private init() {}
    
    /// Reset all repository instances (useful for testing or switching modes)
    public func reset() {
        // Firebase temporarily disabled - always use mocks
        authRepository = MockAuthRepositoryImpl()
        classRepository = MockClassRepositoryImpl()
        flashcardRepository = MockFlashcardRepositoryImpl()
        noteRepository = MockNoteRepositoryImpl()
    }
}
