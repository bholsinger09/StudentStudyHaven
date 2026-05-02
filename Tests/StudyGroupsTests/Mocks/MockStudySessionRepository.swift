import XCTest
import Combine
@testable import Core

/// Mock implementation of StudySessionRepositoryProtocol for testing
class MockStudySessionRepository: GroupStudySessionRepositoryProtocol {
    var studySessions: [GroupStudySession] = []
    var error: Error?
    var createStudySessionCallCount = 0
    var addAttendeeCallCount = 0
    var removeAttendeeCallCount = 0
    
    func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        if let error = error { throw error }
        return studySessions.filter { $0.studyGroupId == groupId }
    }
    
    func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        if let error = error { throw error }
        let now = Date()
        return studySessions.filter { 
            $0.attendeeIds.contains(userId) && 
            $0.scheduledAt > now &&
            $0.status == .scheduled
        }.sorted { $0.scheduledAt < $1.scheduledAt }
    }
    
    func getStudySession(by id: String) async throws -> GroupStudySession {
        if let error = error { throw error }
        guard let session = studySessions.first(where: { $0.id == id }) else {
            throw AppError.notFound("Study session not found")
        }
        return session
    }
    
    func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        createStudySessionCallCount += 1
        if let error = error { throw error }
        studySessions.append(session)
        return session
    }
    
    func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        if let error = error { throw error }
        if let index = studySessions.firstIndex(where: { $0.id == session.id }) {
            studySessions[index] = session
            return session
        }
        throw AppError.notFound("Study session not found")
    }
    
    func deleteStudySession(id: String) async throws {
        if let error = error { throw error }
        studySessions.removeAll { $0.id == id }
    }
    
    func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        addAttendeeCallCount += 1
        if let error = error { throw error }
        guard let index = studySessions.firstIndex(where: { $0.id == sessionId }) else {
            throw AppError.notFound("Study session not found")
        }
        var session = studySessions[index]
        if !session.attendeeIds.contains(userId) {
            session.attendeeIds.append(userId)
        }
        studySessions[index] = session
        return session
    }
    
    func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        removeAttendeeCallCount += 1
        if let error = error { throw error }
        guard let index = studySessions.firstIndex(where: { $0.id == sessionId }) else {
            throw AppError.notFound("Study session not found")
        }
        var session = studySessions[index]
        session.attendeeIds.removeAll { $0 == userId }
        studySessions[index] = session
        return session
    }
    
    func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        fatalError("Not implemented in mock")
    }
    
    func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        fatalError("Not implemented in mock")
    }
    
    func stopObserving() {
        // No-op for mock
    }
}
