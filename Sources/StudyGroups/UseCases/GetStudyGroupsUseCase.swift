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
        // Use provided collegeId or default to "Boise State University" for testing
        let finalCollegeId = collegeId.isEmpty ? "Boise State University" : collegeId
        
        return try await studyGroupRepository.getPublicStudyGroups(for: finalCollegeId, classId: classId)
    }
}
