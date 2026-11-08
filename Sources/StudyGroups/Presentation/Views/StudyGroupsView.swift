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
    @State private var showDeleteConfirmation = false
    @State private var showLeaveConfirmation = false
    @State private var selectedGroupForAction: StudyGroup? = nil
    
    private let createStudyGroupUseCase: CreateStudyGroupUseCase
    private let searchUsersUseCase: SearchUsersUseCase
    private let inviteUserToGroupUseCase: InviteUserToGroupUseCase
    private let leaveStudyGroupUseCase: LeaveStudyGroupUseCase
    private let deleteStudyGroupUseCase: DeleteStudyGroupUseCase
    private let userId: String
    private let collegeId: String
    
    public init(
        viewModel: StudyGroupListViewModel,
        createStudyGroupUseCase: CreateStudyGroupUseCase,
        searchUsersUseCase: SearchUsersUseCase,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase,
        leaveStudyGroupUseCase: LeaveStudyGroupUseCase,
        deleteStudyGroupUseCase: DeleteStudyGroupUseCase,
        userId: String,
        collegeId: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.createStudyGroupUseCase = createStudyGroupUseCase
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        self.leaveStudyGroupUseCase = leaveStudyGroupUseCase
        self.deleteStudyGroupUseCase = deleteStudyGroupUseCase
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
            .alert("Delete Group", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    print("🚪 User cancelled delete")
                }
                if let group = selectedGroupForAction, group.isCreator(userId) {
                    // Creator has option to leave or delete
                    Button("Leave Group", role: .destructive) {
                        print("🚪 Creator chose to leave (not delete) for: \(group.name)")
                        Task {
                            await viewModel.leaveGroup(groupId: group.id)
                        }
                    }
                }
                Button(selectedGroupForAction?.isCreator(userId) == true ? "Delete Group" : "Delete", role: .destructive) {
                    print("🗑️ User confirmed delete for: \(selectedGroupForAction?.name ?? "unknown")")
                    if let group = selectedGroupForAction {
                        Task {
                            await viewModel.deleteGroup(groupId: group.id)
                        }
                    }
                }
            } message: {
                if let group = selectedGroupForAction {
                    if group.isCreator(userId) {
                        Text("You are the creator of '\(group.name)'. Choose to leave the group (others continue) or delete it for everyone.")
                    } else {
                        Text("Are you sure you want to delete '\(group.name)'? This cannot be undone.")
                    }
                }
            }
            .alert("Leave Group", isPresented: $showLeaveConfirmation) {
                Button("Cancel", role: .cancel) {
                    print("🚪 User cancelled leave")
                }
                Button("Leave", role: .destructive) {
                    print("🚪 User confirmed leave for: \(selectedGroupForAction?.name ?? "unknown")")
                    if let group = selectedGroupForAction {
                        Task {
                            await viewModel.leaveGroup(groupId: group.id)
                        }
                    }
                }
            } message: {
                if let group = selectedGroupForAction {
                    Text("Are you sure you want to leave '\(group.name)'?")
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
                    inviteUserToGroupUseCase: inviteUserToGroupUseCase,
                    studyGroupRepository: viewModel.studyGroupRepository,
                    leaveStudyGroupUseCase: leaveStudyGroupUseCase,
                    deleteStudyGroupUseCase: deleteStudyGroupUseCase
                )) {
                    StudyGroupRow(group: group)
                }
                .onAppear {
                    print("📱 NavigationLink for: \(group.name)")
                    print("   Search Use Case: ✅ PRESENT")
                    print("   Invite Use Case: ✅ PRESENT")
                }
                .contextMenu {
                    if group.isCreator(userId) {
                        Button(role: .destructive) {
                            print("🗑️ Context menu: Delete tapped for \(group.name)")
                            selectedGroupForAction = group
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            print("🚪 Context menu: Leave tapped for \(group.name)")
                            selectedGroupForAction = group
                            showLeaveConfirmation = true
                        } label: {
                            Label("Leave", systemImage: "xmark")
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if group.isCreator(userId) {
                        Button(role: .destructive) {
                            print("🗑️ Swipe action: Delete tapped for \(group.name)")
                            selectedGroupForAction = group
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            print("🚪 Swipe action: Leave tapped for \(group.name)")
                            selectedGroupForAction = group
                            showLeaveConfirmation = true
                        } label: {
                            Label("Leave", systemImage: "xmark")
                        }
                    }
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
                QRCodeScannerWrapper(
                    onScan: { scannedId in
                        scannedGroupId = scannedId
                    },
                    onScanComplete: {
                        showJoinSheet = false
                    }
                )
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
            
            // Check if join was successful
            if let error = viewModel.errorMessage {
                print("❌ StudyGroupsView.handleJoinGroup() - Join failed: \(error)")
                joinError = error
                scannedGroupId = nil
                viewModel.errorMessage = nil
                return
            }
            
            print("📱 StudyGroupsView.handleJoinGroup() - Join successful!")
            print("📱 StudyGroupsView.handleJoinGroup() - myGroups count after join: \(viewModel.myGroups.count)")
            scannedGroupId = nil
            showJoinSheet = false
            // Don't reload groups - the group was already added to myGroups during the join
            // CloudKit propagation delays could cause a re-query to show 0 groups temporarily
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
