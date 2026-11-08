import Core
import Foundation

/// Use case for deleting a Study Group
public final class DeleteStudyGroupUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(studyGroupRepository: StudyGroupRepositoryProtocol) {
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(groupId: String, userId: String) async throws {
        // Validate inputs
        guard !groupId.isEmpty else {
            throw AppError.invalidData("Group ID is required")
        }
        
        guard !userId.isEmpty else {
            throw AppError.invalidData("User ID is required")
        }
        
        // Fetch the study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: groupId)
        
        // Check if user is the creator
        guard studyGroup.isCreator(userId) else {
            throw AppError.invalidData("Only the group creator can delete this group")
        }
        
        // Delete the group
        try await studyGroupRepository.deleteStudyGroup(id: groupId)
    }
}
