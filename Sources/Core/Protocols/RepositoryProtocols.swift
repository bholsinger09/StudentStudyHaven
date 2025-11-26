import Combine
import Foundation

/// Protocol for User Repository
public protocol UserRepositoryProtocol {
    func getUser(by id: String) async throws -> User
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
}

/// Protocol for College Repository
public protocol CollegeRepositoryProtocol {
    func getAllColleges() async throws -> [College]
    func getCollege(by id: String) async throws -> College
    func searchColleges(query: String) async throws -> [College]
}

/// Protocol for Class Repository
public protocol ClassRepositoryProtocol {
    func getClasses(for userId: String) async throws -> [Class]
    func getClass(by id: String) async throws -> Class
    func createClass(_ classItem: Class) async throws -> Class
    func updateClass(_ classItem: Class) async throws -> Class
    func deleteClass(id: String) async throws

    // Real-time listeners
    func observeClasses(for userId: String) -> AnyPublisher<[Class], Never>
    func observeClassChanges(for userId: String) -> AnyPublisher<DataChange<Class>, Never>
    func stopObserving()
}

/// Protocol for Flashcard Repository
public protocol FlashcardRepositoryProtocol {
    func getFlashcards(for classId: String) async throws -> [Flashcard]
    func getFlashcard(by id: String) async throws -> Flashcard
    func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard
    func createFlashcards(_ flashcards: [Flashcard]) async throws -> [Flashcard]
    func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard
    func deleteFlashcard(id: String) async throws

    // Real-time listeners
    func observeFlashcards(for classId: String) -> AnyPublisher<[Flashcard], Never>
    func observeFlashcardChanges(for classId: String) -> AnyPublisher<DataChange<Flashcard>, Never>
    func stopObserving()
}

/// Protocol for Note Repository
public protocol NoteRepositoryProtocol {
    func getNotes(for classId: String) async throws -> [Note]
    func getNote(by id: String) async throws -> Note
    func getLinkedNotes(for noteId: String) async throws -> [Note]
    func createNote(_ note: Note) async throws -> Note
    func updateNote(_ note: Note) async throws -> Note
    func deleteNote(id: String) async throws
    func searchNotes(query: String, classId: String?) async throws -> [Note]

    // Real-time listeners
    func observeNotes(for classId: String) -> AnyPublisher<[Note], Never>
    func observeNoteChanges(for classId: String) -> AnyPublisher<DataChange<Note>, Never>
    func stopObserving()
}
