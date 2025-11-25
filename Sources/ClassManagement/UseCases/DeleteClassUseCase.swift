import Core
import Foundation

/// Use case for deleting a class
public final class DeleteClassUseCase {
    private let classRepository: ClassRepositoryProtocol

    public init(classRepository: ClassRepositoryProtocol) {
        self.classRepository = classRepository
    }

    public func execute(classId: String) async throws {
        try await classRepository.deleteClass(id: classId)
    }
}
