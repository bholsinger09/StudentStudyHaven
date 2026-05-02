import Core
import Foundation

/// Use case for inviting a user to a study group
public final class InviteUserToGroupUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(
        studyGroupRepository: StudyGroupRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.studyGroupRepository = studyGroupRepository
        self.userRepository = userRepository
    }
    
    public func execute(
        groupId: String,
        userId: String,
        invitedBy: String
    ) async throws -> StudyGroup {
        // Validate inputs
        guard !groupId.isEmpty else {
            throw AppError.invalidData("Group ID is required")
        }
        
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        guard !invitedBy.isEmpty else {
            throw AppError.invalidData("Inviter user ID is required")
        }
        
        // Get the study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: groupId)
        
        // Verify the inviter is a member of the group
        guard studyGroup.memberIds.contains(invitedBy) else {
            throw AppError.unauthorized
        }
        
        // Verify the user exists
        let _ = try await userRepository.getUser(by: userId)
        
        // Check if user is already a member
        if studyGroup.memberIds.contains(userId) {
            throw AppError.invalidData("User is already a member of this group")
        }
        
        // Check if group is full
        if let maxMembers = studyGroup.maxMembers,
           studyGroup.memberIds.count >= maxMembers {
            throw AppError.invalidData("Study group is full")
        }
        
        // Add the user to the group
        return try await studyGroupRepository.addMember(groupId: groupId, userId: userId)
    }
}
