import Combine
import Foundation

/// Protocol for User Repository
public protocol UserRepositoryProtocol {
    func getUser(by id: String) async throws -> User
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    
    // User search functionality
    func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User]
    func searchUsersByEmail(email: String, collegeId: String) async throws -> User?
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

/// Protocol for Study Group Repository
public protocol StudyGroupRepositoryProtocol {
    func getStudyGroups(for userId: String) async throws -> [StudyGroup]
    func getStudyGroup(by id: String) async throws -> StudyGroup
    func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup]
    func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup
    func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup
    func deleteStudyGroup(id: String) async throws
    func addMember(groupId: String, userId: String) async throws -> StudyGroup
    func removeMember(groupId: String, userId: String) async throws -> StudyGroup
    
    // Real-time listeners
    func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never>
    func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never>
    func stopObserving()
}

/// Protocol for Study Session Repository
public protocol GroupStudySessionRepositoryProtocol {
    func getStudySessions(for groupId: String) async throws -> [GroupStudySession]
    func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession]
    func getStudySession(by id: String) async throws -> GroupStudySession
    func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession
    func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession
    func deleteStudySession(id: String) async throws
    func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession
    func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession
    
    // Real-time listeners
    func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never>
    func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never>
    func stopObserving()
}

/// Protocol for Group Message Repository
public protocol GroupMessageRepositoryProtocol {
    func getMessages(for groupId: String, limit: Int?) async throws -> [GroupMessage]
    func getMessage(by id: String) async throws -> GroupMessage
    func sendMessage(_ message: GroupMessage) async throws -> GroupMessage
    func updateMessage(_ message: GroupMessage) async throws -> GroupMessage
    func deleteMessage(id: String) async throws
    
    // Real-time listeners
    func observeMessages(for groupId: String, limit: Int?) -> AnyPublisher<[GroupMessage], Never>
    func observeNewMessages(for groupId: String) -> AnyPublisher<GroupMessage, Never>
    func stopObserving()
}
