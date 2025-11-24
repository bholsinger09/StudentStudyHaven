import Foundation
import Core

/// Use case for updating an existing class
public final class UpdateClassUseCase {
    private let classRepository: ClassRepositoryProtocol
    
    public init(classRepository: ClassRepositoryProtocol) {
        self.classRepository = classRepository
    }
    
    public func execute(classItem: Class) async throws -> Class {
        // Validate class data
        guard !classItem.name.isEmpty else {
            throw AppError.invalidData("Class name cannot be empty")
        }
        
        guard !classItem.courseCode.isEmpty else {
            throw AppError.invalidData("Course code cannot be empty")
        }
        
        return try await classRepository.updateClass(classItem)
    }
}
