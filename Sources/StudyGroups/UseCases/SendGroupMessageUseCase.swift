import Core
import Foundation

/// Use case for sending a message in a Study Group chat
public final class SendGroupMessageUseCase {
    private let groupMessageRepository: GroupMessageRepositoryProtocol
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    private let maxMessageLength = 2000
    
    public init(
        groupMessageRepository: GroupMessageRepositoryProtocol,
        studyGroupRepository: StudyGroupRepositoryProtocol
    ) {
        self.groupMessageRepository = groupMessageRepository
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(
        studyGroupId: String,
        senderId: String,
        senderName: String,
        content: String
    ) async throws -> GroupMessage {
        // Validate inputs
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidData("Message content cannot be empty")
        }
        
        guard content.count <= maxMessageLength else {
            throw AppError.invalidData("Message content cannot exceed \(maxMessageLength) characters")
        }
        
        guard !studyGroupId.isEmpty else {
            throw AppError.invalidData("Study group ID is required")
        }
        
        guard !senderId.isEmpty else {
            throw AppError.invalidData("Sender ID is required")
        }
        
        guard !senderName.isEmpty else {
            throw AppError.invalidData("Sender name is required")
        }
        
        // Verify user is a member of the study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: studyGroupId)
        guard studyGroup.isMember(senderId) else {
            throw AppError.unauthorized
        }
        
        // Create and send message
        let message = GroupMessage(
            studyGroupId: studyGroupId,
            senderId: senderId,
            senderName: senderName,
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            messageType: .text
        )
        
        return try await groupMessageRepository.sendMessage(message)
    }
}
