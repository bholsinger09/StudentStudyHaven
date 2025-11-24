import Foundation
import Core

/// Use case for deleting a class
public final class DeleteClassUseCase {
    private let classRepository: ClassRepositoryProtocol
    
    public init(classRepository: ClassRepositoryProtocol) {
        self.classRepository = classRepository
    }
    
    public func execute(classId: UUID) async throws {
        try await classRepository.deleteClass(id: classId)
    }
}
