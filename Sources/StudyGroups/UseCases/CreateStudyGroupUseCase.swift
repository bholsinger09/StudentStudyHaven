import Core
import Foundation

/// Use case for creating a new Study Group
public final class CreateStudyGroupUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(studyGroupRepository: StudyGroupRepositoryProtocol) {
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(
        name: String,
        classId: String,
        collegeId: String,
        description: String?,
        createdBy: String,
        maxMembers: Int?,
        isPublic: Bool
    ) async throws -> StudyGroup {
        // Validate inputs
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidData("Study group name cannot be empty")
        }
        
        guard !classId.isEmpty else {
            throw AppError.invalidData("Class ID is required")
        }
        
        guard !collegeId.isEmpty else {
            throw AppError.invalidData("College ID is required")
        }
        
        guard !createdBy.isEmpty else {
            throw AppError.invalidData("Creator user ID is required")
        }
        
        // Validate maxMembers if provided
        if let maxMembers = maxMembers {
            guard maxMembers >= 2 else {
                throw AppError.invalidData("Study group must allow at least 2 members")
            }
        }
        
       // Create study group with creator as first member
        let studyGroup = StudyGroup(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            classId: classId,
            collegeId: collegeId,
            description: description,
            createdBy: createdBy,
            memberIds: [createdBy], // Creator automatically joins
            maxMembers: maxMembers,
            isPublic: isPublic
        )
        
        return try await studyGroupRepository.createStudyGroup(studyGroup)
    }
}
