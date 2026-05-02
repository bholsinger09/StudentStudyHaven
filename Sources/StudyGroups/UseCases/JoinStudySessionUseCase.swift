import Core
import Foundation

/// Use case for joining a Study Session
public final class JoinStudySessionUseCase {
    private let studySessionRepository: GroupStudySessionRepositoryProtocol
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(
        studySessionRepository: GroupStudySessionRepositoryProtocol,
        studyGroupRepository: StudyGroupRepositoryProtocol
    ) {
        self.studySessionRepository = studySessionRepository
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(sessionId: String, userId: String) async throws -> GroupStudySession {
        // Validate inputs
        guard !sessionId.isEmpty else {
            throw AppError.invalidData("Session ID is required")
        }
        
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        // Fetch the study session
        let session = try await studySessionRepository.getStudySession(by: sessionId)
        
        // Verify user is a member of the associated study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: session.studyGroupId)
        guard studyGroup.isMember(userId) else {
            throw AppError.unauthorized
        }
        
        // Check if user is already attending
        guard !session.isAttending(userId) else {
            throw AppError.invalidData("You are already attending this session")
        }
        
        // Check if session is full
        guard !session.isFull else {
            throw AppError.invalidData("This session is full")
        }
        
        // Check if session is still in the future
        guard session.status == .scheduled else {
            throw AppError.invalidData("Cannot join a session that is not scheduled")
        }
        
        // Add user as attendee
        return try await studySessionRepository.addAttendee(sessionId: sessionId, userId: userId)
    }
}
