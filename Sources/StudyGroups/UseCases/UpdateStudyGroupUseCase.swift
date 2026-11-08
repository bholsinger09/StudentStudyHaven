import Foundation
import Core

/// Use case for updating study group details (name, description)
public class UpdateStudyGroupUseCase {
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(studyGroupRepository: StudyGroupRepositoryProtocol) {
        self.studyGroupRepository = studyGroupRepository
    }
    
    /// Updates study group with new name and/or description
    /// Only the creator can update group details
    public func execute(
        groupId: String,
        userId: String,
        name: String? = nil,
        description: String? = nil
    ) async throws {
        // Fetch current group
        let currentGroup = try await studyGroupRepository.getStudyGroup(by: groupId)
        
        // Validate user is creator
        guard currentGroup.isCreator(userId) else {
            throw AppError.unauthorized
        }
        
        // Validate at least one field is being updated
        guard name != nil || description != nil else {
            throw AppError.invalidData("No fields to update")
        }
        
        // Validate name is not empty if provided
        if let name = name, name.trimmingCharacters(in: .whitespaces).isEmpty {
            throw AppError.invalidData("Group name cannot be empty")
        }
        
        // Create updated group
        var updatedGroup = currentGroup
        if let name = name {
            updatedGroup.name = name.trimmingCharacters(in: .whitespaces)
        }
        if let description = description {
            updatedGroup.description = description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description.trimmingCharacters(in: .whitespaces)
        }
        updatedGroup.updatedAt = Date()
        
        // Update in repository
        _ = try await studyGroupRepository.updateStudyGroup(updatedGroup)
        
        print("✅ UpdateStudyGroupUseCase: Successfully updated group '\(updatedGroup.name)'")
    }
}

