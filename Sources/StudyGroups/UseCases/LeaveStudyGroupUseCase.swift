import Core
import Foundation

/// Use case for leaving a Study Group
public final class LeaveStudyGroupUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(studyGroupRepository: StudyGroupRepositoryProtocol) {
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(groupId: String, userId: String) async throws -> StudyGroup {
        // Validate inputs
        guard !groupId.isEmpty else {
            throw AppError.invalidData("Group ID is required")
        }
        
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        // Fetch the study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: groupId)
        
        // Check if user is a member
        guard studyGroup.isMember(userId) else {
            throw AppError.invalidData("You are not a member of this study group")
        }
        
        // Prevent creator from leaving (they must delete the group instead)
        guard !studyGroup.isCreator(userId) else {
            throw AppError.invalidData("Group creator cannot leave. Delete the group instead.")
        }
        
        // Remove user from group
        return try await studyGroupRepository.removeMember(groupId: groupId, userId: userId)
    }
}
