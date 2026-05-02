import Combine
import Core
import Foundation

/// Mock implementation of StudySessionRepository for development and testing
public final class MockStudySessionRepositoryImpl: GroupStudySessionRepositoryProtocol {
    private var studySessions: [String: GroupStudySession] = [:]
    private let studySessionsSubject = CurrentValueSubject<[GroupStudySession], Never>([])
    private let changesSubject = PassthroughSubject<DataChange<GroupStudySession>, Never>()
    private var isObserving = false
    
    public init() {}
    
    public func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return studySessions.values.filter { $0.studyGroupId == groupId }
    }
    
    public func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let now = Date()
        return studySessions.values.filter {
            $0.attendeeIds.contains(userId) &&
            $0.scheduledAt > now &&
            $0.status == .scheduled
        }.sorted { $0.scheduledAt < $1.scheduledAt }
    }
    
    public func getStudySession(by id: String) async throws -> GroupStudySession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let studySession = studySessions[id] else {
            throw AppError.notFound("Study session not found")
        }
        
        return studySession
    }
    
    public func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        studySessions[session.id] = session
        
        if isObserving {
            changesSubject.send(DataChange(type: .added, item: session))
            updateStudySessionsSubject()
        }
        
        return session
    }
    
    public func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard studySessions[session.id] != nil else {
            throw AppError.notFound("Study session not found")
        }
        
        var updatedSession = session
        updatedSession.updatedAt = Date()
        studySessions[session.id] = updatedSession
        
        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: updatedSession))
            updateStudySessionsSubject()
        }
        
        return updatedSession
    }
    
    public func deleteStudySession(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let deletedSession = studySessions[id] else {
            throw AppError.notFound("Study session not found")
        }
        
        studySessions.removeValue(forKey: id)
        
        if isObserving {
            changesSubject.send(DataChange(type: .removed, item: deletedSession))
            updateStudySessionsSubject()
        }
    }
    
    public func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard var session = studySessions[sessionId] else {
            throw AppError.notFound("Study session not found")
        }
        
        if !session.attendeeIds.contains(userId) {
            session.attendeeIds.append(userId)
            session.updatedAt = Date()
            studySessions[sessionId] = session
            
            if isObserving {
                changesSubject.send(DataChange(type: .modified, item: session))
                updateStudySessionsSubject()
            }
        }
        
        return session
    }
    
    public func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard var session = studySessions[sessionId] else {
            throw AppError.notFound("Study session not found")
        }
        
        session.attendeeIds.removeAll { $0 == userId }
        session.updatedAt = Date()
        studySessions[sessionId] = session
        
        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: session))
            updateStudySessionsSubject()
        }
        
        return session
    }
    
    // MARK: - Real-time listeners
    
    public func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialSessions = try await getStudySessions(for: groupId)
                studySessionsSubject.send(initialSessions)
            } catch {
                studySessionsSubject.send([])
            }
        }
        return studySessionsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        isObserving = true
        return changesSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        isObserving = false
    }
    
    // MARK: - Private helpers
    
    private func updateStudySessionsSubject() {
        let allSessions = Array(studySessions.values)
        studySessionsSubject.send(allSessions)
    }
}
