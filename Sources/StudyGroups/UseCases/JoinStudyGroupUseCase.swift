import Core
import Foundation

/// Use case for joining an existing Study Group
public final class JoinStudyGroupUseCase {
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
        
        // Check if user is already a member
        guard !studyGroup.isMember(userId) else {
            throw AppError.invalidData("You are already a member of this study group")
        }
        
        // Check if group is full
        guard !studyGroup.isFull else {
            throw AppError.invalidData("This study group is full")
        }
        
        // Add user as member
        return try await studyGroupRepository.addMember(groupId: groupId, userId: userId)
    }
}
