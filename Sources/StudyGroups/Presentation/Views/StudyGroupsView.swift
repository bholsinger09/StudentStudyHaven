import Core
import SwiftUI

/// Study Groups List View
public struct StudyGroupsView: View {
    @StateObject private var viewModel: StudyGroupListViewModel
    @State private var selectedTab = 0
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var scannedGroupId: String? = nil
    @State private var joinError: String? = nil
    
    private let createStudyGroupUseCase: CreateStudyGroupUseCase
    private let searchUsersUseCase: SearchUsersUseCase
    private let inviteUserToGroupUseCase: InviteUserToGroupUseCase
    private let userId: String
    private let collegeId: String
    
    public init(
        viewModel: StudyGroupListViewModel,
        createStudyGroupUseCase: CreateStudyGroupUseCase,
        searchUsersUseCase: SearchUsersUseCase,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase,
        userId: String,
        collegeId: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.createStudyGroupUseCase = createStudyGroupUseCase
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        self.userId = userId
        self.collegeId = collegeId
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("My Groups").tag(0)
                    Text("Discover").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected tab
                if selectedTab == 0 {
                    myGroupsView
                } else {
                    discoverGroupsView
                }
            }
            .navigationTitle("Study Groups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                NavigationStack {
                    CreateStudyGroupView(
                        viewModel: CreateStudyGroupViewModel(
                            createStudyGroupUseCase: createStudyGroupUseCase,
                            userId: userId,
                            collegeId: collegeId
                        ),
                        onDismiss: {
                            showCreateSheet = false
                            Task {
                                await viewModel.loadMyGroups()
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $showJoinSheet) {
                joinSheetContent
            }
            .onChange(of: scannedGroupId) { newGroupId in
                if let groupId = newGroupId {
                    handleJoinGroup(groupId: groupId)
                }
            }
            .task {
                await viewModel.loadMyGroups()
                await viewModel.loadDiscoverGroups()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Join Error", isPresented: .constant(joinError != nil)) {
                Button("OK") {
                    joinError = nil
                }
            } message: {
                if let error = joinError {
                    Text(error)
                }
            }
        }
    }
    
    @ViewBuilder
    private var myGroupsView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.myGroups.isEmpty {
            EmptyStateView(
                icon: "person.3",
                title: "No Study Groups",
                message: "Join or create a study group to collaborate with classmates",
                primaryAction: { showCreateSheet = true },
                secondaryAction: { showJoinSheet = true }
            )
        } else {
            List(viewModel.myGroups) { group in
                NavigationLink(destination: StudyGroupDetailView(
                    groupId: group.id,
                    studyGroup: group,
                    currentUserId: userId,
                    collegeId: collegeId,
                    searchUsersUseCase: searchUsersUseCase,
                    inviteUserToGroupUseCase: inviteUserToGroupUseCase
                )) {
                    StudyGroupRow(group: group)
                }
                .onAppear {
                    print("📱 NavigationLink for: \(group.name)")
                    print("   Search Use Case: ✅ PRESENT")
                    print("   Invite Use Case: ✅ PRESENT")
                }
            }
            .refreshable {
                await viewModel.loadMyGroups()
            }
        }
    }
    
    @ViewBuilder
    private var discoverGroupsView: some View {
        if viewModel.discoverGroups.isEmpty {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Groups Found",
                message: "No public study groups available in your college right now"
            )
        } else {
            List(viewModel.discoverGroups) { group in
                DiscoverGroupRow(group: group) {
                    Task {
                        await viewModel.joinGroup(group)
                    }
                }
            }
            .refreshable {
                await viewModel.loadDiscoverGroups()
            }
        }
    }
    
    private var joinSheetContent: some View {
        NavigationStack {
            VStack {
                QRCodeScannerWrapper(onScan: { scannedId in
                    scannedGroupId = scannedId
                })
            }
            .navigationTitle("Join Group")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showJoinSheet = false
                    }
                }
            }
            #endif
        }
    }
    
    private func handleJoinGroup(groupId: String) {
        // Extract groupId from QR code URL format: studyhaven://group/{groupId}
        let extractedGroupId: String
        if groupId.hasPrefix("studyhaven://group/") {
            // Remove the prefix to get just the group ID
            extractedGroupId = String(groupId.dropFirst("studyhaven://group/".count))
            print("📱 StudyGroupsView.handleJoinGroup() - Extracted groupId: '\(extractedGroupId)' from QR: '\(groupId)'")
        } else {
            // Fallback: assume it's already just the group ID
            print("📱 StudyGroupsView.handleJoinGroup() - Using groupId as-is: '\(groupId)'")
            extractedGroupId = groupId
        }
        
        if extractedGroupId.isEmpty {
            print("❌ StudyGroupsView.handleJoinGroup() - Empty groupId!")
            joinError = "Invalid QR code: empty group ID"
            scannedGroupId = nil
            return
        }
        
        print("📱 StudyGroupsView.handleJoinGroup() - Starting join task for groupId: '\(extractedGroupId)', userId: '\(userId)'")
        Task {
            print("📱 StudyGroupsView.handleJoinGroup() - Inside task, calling viewModel.joinGroupByQRCode()")
            await viewModel.joinGroupByQRCode(groupId: extractedGroupId, userId: userId)
            print("📱 StudyGroupsView.handleJoinGroup() - Back from joinGroupByQRCode(), reloading groups")
            scannedGroupId = nil
            showJoinSheet = false
            await viewModel.loadMyGroups()
            print("📱 StudyGroupsView.handleJoinGroup() - Complete! myGroups count: \(viewModel.myGroups.count)")
        }
    }
}

// MARK: - Study Group Row
struct StudyGroupRow: View {
    let group: StudyGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(group.name)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: group.isPublic ? "globe" : "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            if let description = group.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("\(group.memberIds.count) members", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let max = group.maxMembers {
                    Text("/ \(max)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if group.isFull {
                    Text("FULL")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Discover Group Row
struct DiscoverGroupRow: View {
    let group: StudyGroup
    let onJoin: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.name)
                    .font(.headline)
                
                if let description = group.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Label("\(group.memberIds.count) members", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onJoin) {
                if group.isFull {
                    Text("Full")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Join")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
            }
            .disabled(group.isFull)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var primaryAction: (() -> Void)? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                if let action = primaryAction {
                    Button("Create Group") {
                        action()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let action = secondaryAction {
                    Button("Join via QR Code") {
                        action()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
