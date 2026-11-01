import SwiftUI
import Core

/// View for adding members to a study group - provides QR code scan and search options
public struct AddMemberView: View {
    let group: StudyGroup
    let currentUserId: String
    let collegeId: String
    let searchUsersUseCase: SearchUsersUseCase?
    let inviteUserToGroupUseCase: InviteUserToGroupUseCase?
    @State private var showQRCode = false
    @State private var showUserSearch = false
    @State private var showQRScanner = false
    @Environment(\.dismiss) private var dismiss
    
    public init(
        group: StudyGroup,
        currentUserId: String,
        collegeId: String,
        searchUsersUseCase: SearchUsersUseCase?,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase?
    ) {
        self.group = group
        self.currentUserId = currentUserId
        self.collegeId = collegeId
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Display QR Code Section
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Share via QR Code")
                            .font(.headline)
                        
                        Text("Display QR code for others to scan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemBlue).opacity(0.1))
                    .cornerRadius(12)
                    
                    Button(action: { showQRCode = true }) {
                        Label("Show QR Code", systemImage: "qrcode.viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                Divider()
                    .padding(.vertical, 12)
                
                // Search User Section
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Search & Invite")
                            .font(.headline)
                        
                        Text("Find users by name and email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(.systemGreen).opacity(0.1))
                    .cornerRadius(12)
                    
                    Button(action: { showUserSearch = true }) {
                        Label("Search Members", systemImage: "person.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(searchUsersUseCase == nil || inviteUserToGroupUseCase == nil)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Member")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showQRCode) {
            GroupQRCodeView(group: group)
        }
        .sheet(isPresented: $showUserSearch) {
            if let searchUseCase = searchUsersUseCase,
               let inviteUseCase = inviteUserToGroupUseCase {
                UserSearchView(
                    viewModel: UserSearchViewModel(
                        searchUsersUseCase: searchUseCase,
                        inviteUserToGroupUseCase: inviteUseCase,
                        groupId: group.id,
                        currentUserId: currentUserId,
                        collegeId: collegeId
                    )
                )
            }
        }
    }
}
