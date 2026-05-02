import Core
import Foundation

/// Use case for retrieving Group Messages
public final class GetGroupMessagesUseCase {
    private let groupMessageRepository: GroupMessageRepositoryProtocol
    
    public init(groupMessageRepository: GroupMessageRepositoryProtocol) {
        self.groupMessageRepository = groupMessageRepository
    }
    
    /// Get messages for a study group with optional limit
    public func execute(for groupId: String, limit: Int? = 100) async throws -> [GroupMessage] {
        guard !groupId.isEmpty else {
            throw AppError.invalidData("Group ID is required")
        }
        
        return try await groupMessageRepository.getMessages(for: groupId, limit: limit)
    }
}
