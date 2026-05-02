import Combine
import Core
import Foundation

/// ViewModel for Study Group Detail screen
@MainActor
public final class StudyGroupDetailViewModel: ObservableObject {
    @Published public var studyGroup: StudyGroup?
    @Published public var sessions: [GroupStudySession] = []
    @Published public var messages: [GroupMessage] = []
    @Published public var messageText: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let groupId: String
    private let userId: String
    private let userName: String
    private let getStudySessionsUseCase: GetStudySessionsUseCase
    private let getGroupMessagesUseCase: GetGroupMessagesUseCase
    private let sendGroupMessageUseCase: SendGroupMessageUseCase
    private let leaveStudyGroupUseCase: LeaveStudyGroupUseCase
    
    public var onGroupLeft: (() -> Void)?
    
    public init(
        groupId: String,
        userId: String,
        userName: String,
        getStudySessionsUseCase: GetStudySessionsUseCase,
        getGroupMessagesUseCase: GetGroupMessagesUseCase,
        sendGroupMessageUseCase: SendGroupMessageUseCase,
        leaveStudyGroupUseCase: LeaveStudyGroupUseCase
    ) {
        self.groupId = groupId
        self.userId = userId
        self.userName = userName
        self.getStudySessionsUseCase = getStudySessionsUseCase
        self.getGroupMessagesUseCase = getGroupMessagesUseCase
        self.sendGroupMessageUseCase = sendGroupMessageUseCase
        self.leaveStudyGroupUseCase = leaveStudyGroupUseCase
    }
    
    public func loadSessions() async {
        do {
            sessions = try await getStudySessionsUseCase.execute(for: groupId)
            // Sort by scheduled date
            sessions.sort { $0.scheduledAt < $1.scheduledAt }
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load sessions"
        }
    }
    
    public func loadMessages() async {
        do {
            messages = try await getGroupMessagesUseCase.execute(for: groupId, limit: 100)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load messages"
        }
    }
    
    public func sendMessage() async {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let text = messageText
        messageText = "" // Clear immediately for better UX
        
        do {
            let message = try await sendGroupMessageUseCase.execute(
                studyGroupId: groupId,
                senderId: userId,
                senderName: userName,
                content: text
            )
            messages.insert(message, at: 0) // Add to top of list
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            messageText = text // Restore if failed
        } catch {
            errorMessage = "Failed to send message"
            messageText = text
        }
    }
    
    public var isCreator: Bool {
        studyGroup?.createdBy == userId
    }
    
    public func leaveGroup() async -> Bool {
        guard let group = studyGroup else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await leaveStudyGroupUseCase.execute(groupId: group.id, userId: userId)
            onGroupLeft?()
            isLoading = false
            return true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to leave group"
            isLoading = false
            return false
        }
    }
}
