import Combine
import Core
import Foundation

/// ViewModel for searching and inviting users to study groups
@MainActor
public final class UserSearchViewModel: ObservableObject {
    @Published public var firstName: String = ""
    @Published public var email: String = ""
    @Published public var searchResults: [User] = []
    @Published public var isSearching: Bool = false
    @Published public var isInviting: Bool = false
    @Published public var errorMessage: String?
    @Published public var successMessage: String?
    @Published public var showError: Bool = false
    @Published public var showSuccess: Bool = false
    
    private let searchUsersUseCase: SearchUsersUseCase
    private let inviteUserToGroupUseCase: InviteUserToGroupUseCase
    private let groupId: String
    private let currentUserId: String
    private let collegeId: String
    
    public init(
        searchUsersUseCase: SearchUsersUseCase,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase,
        groupId: String,
        currentUserId: String,
        collegeId: String
    ) {
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        self.groupId = groupId
        self.currentUserId = currentUserId
        self.collegeId = collegeId
    }
    
    public func searchUsers() async {
        guard !firstName.isEmpty && !email.isEmpty else {
            errorMessage = "Please enter both first name and email"
            showError = true
            return
        }
        
        isSearching = true
        errorMessage = nil
        successMessage = nil
        searchResults = []
        
        do {
            searchResults = try await searchUsersUseCase.execute(
                firstName: firstName,
                email: email,
                collegeId: collegeId
            )
            
            if searchResults.isEmpty {
                errorMessage = "No users found matching the criteria"
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isSearching = false
    }
    
    public func inviteUser(_ user: User) async {
        isInviting = true
        errorMessage = nil
        successMessage = nil
        
        do {
            _ = try await inviteUserToGroupUseCase.execute(
                groupId: groupId,
                userId: user.id,
                invitedBy: currentUserId
            )
            
            successMessage = "\(user.name) has been added to the group!"
            showSuccess = true
            
            // Clear search results and form after successful invitation
            firstName = ""
            email = ""
            searchResults = []
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isInviting = false
    }
    
    public func clearResults() {
        searchResults = []
        errorMessage = nil
        successMessage = nil
    }
}
