import Core
import Foundation

/// Use case for retrieving Study Groups for a user
public final class GetStudyGroupsUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(studyGroupRepository: StudyGroupRepositoryProtocol) {
        self.studyGroupRepository = studyGroupRepository
    }
    
    /// Get all study groups the user is a member of
    public func execute(for userId: String) async throws -> [StudyGroup] {
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        return try await studyGroupRepository.getStudyGroups(for: userId)
    }
    
    /// Get public study groups for discovery (by college and optionally class)
    public func executeForDiscovery(collegeId: String, classId: String? = nil) async throws -> [StudyGroup] {
        guard !collegeId.isEmpty else {
            throw AppError.invalidData("College ID is required")
        }
        
        return try await studyGroupRepository.getPublicStudyGroups(for: collegeId, classId: classId)
    }
}
