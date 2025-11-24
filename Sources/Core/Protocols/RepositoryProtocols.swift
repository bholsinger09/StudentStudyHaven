import Foundation

/// Protocol for User Repository
public protocol UserRepositoryProtocol {
    func getUser(by id: UUID) async throws -> User
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: UUID) async throws
}

/// Protocol for College Repository
public protocol CollegeRepositoryProtocol {
    func getAllColleges() async throws -> [College]
    func getCollege(by id: UUID) async throws -> College
    func searchColleges(query: String) async throws -> [College]
}

/// Protocol for Class Repository
public protocol ClassRepositoryProtocol {
    func getClasses(for userId: UUID) async throws -> [Class]
    func getClass(by id: UUID) async throws -> Class
    func createClass(_ classItem: Class) async throws -> Class
    func updateClass(_ classItem: Class) async throws -> Class
    func deleteClass(id: UUID) async throws
}

/// Protocol for Flashcard Repository
public protocol FlashcardRepositoryProtocol {
    func getFlashcards(for classId: UUID) async throws -> [Flashcard]
    func getFlashcard(by id: UUID) async throws -> Flashcard
    func createFlashcard(_ flashcard: Flashcard) async throws -> Flashcard
    func createFlashcards(_ flashcards: [Flashcard]) async throws -> [Flashcard]
    func updateFlashcard(_ flashcard: Flashcard) async throws -> Flashcard
    func deleteFlashcard(id: UUID) async throws
}

/// Protocol for Note Repository
public protocol NoteRepositoryProtocol {
    func getNotes(for classId: UUID) async throws -> [Note]
    func getNote(by id: UUID) async throws -> Note
    func getLinkedNotes(for noteId: UUID) async throws -> [Note]
    func createNote(_ note: Note) async throws -> Note
    func updateNote(_ note: Note) async throws -> Note
    func deleteNote(id: UUID) async throws
    func searchNotes(query: String, classId: UUID?) async throws -> [Note]
}
