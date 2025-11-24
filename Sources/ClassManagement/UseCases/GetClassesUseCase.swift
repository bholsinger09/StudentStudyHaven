import Foundation
import Core

/// Use case for getting all classes for a user
public final class GetClassesUseCase {
    private let classRepository: ClassRepositoryProtocol
    
    public init(classRepository: ClassRepositoryProtocol) {
        self.classRepository = classRepository
    }
    
    public func execute(userId: UUID) async throws -> [Class] {
        return try await classRepository.getClasses(for: userId)
    }
}
