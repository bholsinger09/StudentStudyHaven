import Core
import Foundation

/// Use case for retrieving Study Sessions
public final class GetStudySessionsUseCase {
    private let studySessionRepository: GroupStudySessionRepositoryProtocol
    
    public init(studySessionRepository: GroupStudySessionRepositoryProtocol) {
        self.studySessionRepository = studySessionRepository
    }
    
    /// Get all study sessions for a specific group
    public func execute(for groupId: String) async throws -> [GroupStudySession] {
        guard !groupId.isEmpty else {
            throw AppError.invalidData("Group ID is required")
        }
        
        return try await studySessionRepository.getStudySessions(for: groupId)
    }
    
    /// Get upcoming sessions for a user across all their groups
    public func executeUpcoming(for userId: String) async throws -> [GroupStudySession] {
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        return try await studySessionRepository.getUpcomingSessions(for: userId)
    }
}
