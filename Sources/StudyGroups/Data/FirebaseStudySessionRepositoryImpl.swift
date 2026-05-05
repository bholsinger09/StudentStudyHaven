import Core
import Combine
import Foundation

/// DEPRECATED: Legacy Firebase SDK implementation
/// This file is kept for compatibility but is no longer used.
/// Use REST API implementation instead.
public class FirebaseStudySessionRepositoryImpl: GroupStudySessionRepositoryProtocol {
    
    private var sessionsSubject = CurrentValueSubject<[GroupStudySession], Never>([])
    private var changesSubject = PassthroughSubject<DataChange<GroupStudySession>, Never>()
    
    public init() {}
    
    // MARK: - GroupStudySessionRepositoryProtocol Implementation
    
    public func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func getStudySession(by id: String) async throws -> GroupStudySession {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func deleteStudySession(id: String) async throws {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    public func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        throw AppError.unknown("Firebase SDK implementation is deprecated")
    }
    
    // MARK: - Real-time Listeners
    
    public func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        return sessionsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        return changesSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        // No-op
    }
}
