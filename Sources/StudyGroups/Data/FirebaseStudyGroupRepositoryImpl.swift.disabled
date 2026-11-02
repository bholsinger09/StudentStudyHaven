import Core
import Combine
import Foundation

/// DEPRECATED: Legacy Firebase SDK implementation
/// This file is kept for compatibility but is no longer used.
/// Use REST API implementation instead.
public class FirebaseStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    
    private var groupsSubject = CurrentValueSubject<[StudyGroup], Never>([])
    private var changesSubject = PassthroughSubject<DataChange<StudyGroup>, Never>()
    
    public init() {}
    
    // MARK: - StudyGroupRepositoryProtocol Implementation
    
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func deleteStudyGroup(id: String) async throws {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    // MARK: - Real-time Listeners
    
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        return groupsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        return changesSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        // No-op
    }
}
