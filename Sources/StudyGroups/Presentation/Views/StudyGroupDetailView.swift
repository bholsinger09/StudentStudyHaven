import Core
import SwiftUI

/// Study Group Detail View
public struct StudyGroupDetailView: View {
    let groupId: String
    let currentUserId: String
    let collegeId: String
    let searchUsersUseCase: SearchUsersUseCase?
    let inviteUserToGroupUseCase: InviteUserToGroupUseCase?
    let studyGroupRepository: StudyGroupRepositoryProtocol?
    let leaveStudyGroupUseCase: LeaveStudyGroupUseCase?
    let deleteStudyGroupUseCase: DeleteStudyGroupUseCase?
    
    @State private var studyGroup: StudyGroup
    @State private var selectedTab = 0
    @State private var showLeaveConfirmation = false
    @State private var leaveErrorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    public init(
        groupId: String,
        studyGroup: StudyGroup,
        currentUserId: String,
        collegeId: String,
        searchUsersUseCase: SearchUsersUseCase? = nil,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase? = nil,
        studyGroupRepository: StudyGroupRepositoryProtocol? = nil,
        leaveStudyGroupUseCase: LeaveStudyGroupUseCase? = nil,
        deleteStudyGroupUseCase: DeleteStudyGroupUseCase? = nil
    ) {
        self.groupId = groupId
        _studyGroup = State(initialValue: studyGroup)
        self.currentUserId = currentUserId
        self.collegeId = collegeId
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        self.studyGroupRepository = studyGroupRepository
        self.leaveStudyGroupUseCase = leaveStudyGroupUseCase
        self.deleteStudyGroupUseCase = deleteStudyGroupUseCase
        
        print("🔍 StudyGroupDetailView INIT")
        print("   Group: \(studyGroup.name)")
        print("   Current User: \(currentUserId)")
        print("   Search Use Case: \(searchUsersUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Invite Use Case: \(inviteUserToGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Repository: \(studyGroupRepository != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Leave Use Case: \(leaveStudyGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Delete Use Case: \(deleteStudyGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("View", selection: $selectedTab) {
                Text("Chat").tag(0)
                Text("Sessions").tag(1)
                Text("Members").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            TabView(selection: $selectedTab) {
                GroupChatView(groupId: groupId)
                    .tag(0)
                
                GroupSessionsView(groupId: groupId)
                    .tag(1)
                
                GroupMembersView(
                    group: studyGroup,
                    currentUserId: currentUserId,
                    collegeId: collegeId,
                    searchUsersUseCase: searchUsersUseCase,
                    inviteUserToGroupUseCase: inviteUserToGroupUseCase,
                    leaveStudyGroupUseCase: leaveStudyGroupUseCase,
                    deleteStudyGroupUseCase: deleteStudyGroupUseCase,
                    showLeaveConfirmation: $showLeaveConfirmation
                )
                    .tag(2)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
        .navigationTitle(studyGroup.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if studyGroup.isCreator(currentUserId) {
                    Menu {
                        Button(role: .destructive) {
                            print("🗑️ Delete button tapped in toolbar")
                            showLeaveConfirmation = true
                        } label: {
                            Label("Delete Group", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                } else {
                    Button {
                        print("🚪 Leave button tapped in toolbar")
                        showLeaveConfirmation = true
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .alert("Manage Group", isPresented: $showLeaveConfirmation) {
            let isCreator = studyGroup.isCreator(currentUserId)
            
            Button("Cancel", role: .cancel) {
                print("🚪 User cancelled")
            }
            
            if isCreator {
                Button("Leave Group", role: .destructive) {
                    print("🚪 Creator tapped Leave (without deleting)")
                    print("   Leave Use Case: \(leaveStudyGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
                    
                    Task {
                        do {
                            print("🚪 Attempting to leave group as creator...")
                            guard let leaveUseCase = leaveStudyGroupUseCase else {
                                leaveErrorMessage = "Leave use case not available"
                                return
                            }
                            _ = try await leaveUseCase.execute(groupId: groupId, userId: currentUserId)
                            print("✅ Creator left group successfully (others remain)")
                            await MainActor.run {
                                dismiss()
                            }
                        } catch let error as AppError {
                            print("❌ Error leaving: \(error.localizedDescription)")
                            leaveErrorMessage = error.localizedDescription
                        } catch {
                            print("❌ Error leaving: \(error)")
                            leaveErrorMessage = "Failed to leave group"
                        }
                    }
                }
                
                Button("Delete Group", role: .destructive) {
                    print("🗑️ Creator tapped Delete")
                    print("   Delete Use Case: \(deleteStudyGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
                    
                    Task {
                        do {
                            print("🗑️ Attempting to delete group...")
                            guard let deleteUseCase = deleteStudyGroupUseCase else {
                                leaveErrorMessage = "Delete use case not available"
                                return
                            }
                            try await deleteUseCase.execute(groupId: groupId, userId: currentUserId)
                            print("✅ Group deleted successfully for everyone")
                            await MainActor.run {
                                dismiss()
                            }
                        } catch let error as AppError {
                            print("❌ Error deleting: \(error.localizedDescription)")
                            leaveErrorMessage = error.localizedDescription
                        } catch {
                            print("❌ Error deleting: \(error)")
                            leaveErrorMessage = "Failed to delete group"
                        }
                    }
                }
            } else {
                Button("Leave Group", role: .destructive) {
                    print("🚪 Member tapped Leave")
                    print("   Leave Use Case: \(leaveStudyGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
                    
                    Task {
                        do {
                            print("🚪 Attempting to leave group as member...")
                            guard let leaveUseCase = leaveStudyGroupUseCase else {
                                leaveErrorMessage = "Leave use case not available"
                                return
                            }
                            _ = try await leaveUseCase.execute(groupId: groupId, userId: currentUserId)
                            print("✅ Left group successfully")
                            await MainActor.run {
                                dismiss()
                            }
                        } catch let error as AppError {
                            print("❌ Error: \(error.localizedDescription)")
                            leaveErrorMessage = error.localizedDescription
                        } catch {
                            print("❌ Error: \(error)")
                            leaveErrorMessage = "Failed to leave group"
                        }
                    }
                }
            }
        } message: {
            if studyGroup.isCreator(currentUserId) {
                Text("You are the creator. You can leave this group (others continue) or delete it for everyone.")
            } else {
                Text("Are you sure you want to leave this group?")
            }
        }
        .alert("Error", isPresented: .constant(leaveErrorMessage != nil)) {
            Button("OK") {
                leaveErrorMessage = nil
            }
        } message: {
            if let error = leaveErrorMessage {
                Text(error)
            }
        }
        .task {
            // Periodically refresh the group data to get updates from other devices
            while true {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                if let repository = studyGroupRepository {
                    do {
                        let updated = try await repository.getStudyGroup(by: groupId)
                        await MainActor.run {
                            studyGroup = updated
                        }
                    } catch {
                        print("⚠️ StudyGroupDetailView: Failed to refresh group - \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Group Chat View
struct GroupChatView: View {
    let groupId: String
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Chat will be implemented with real-time messaging")
                    .padding()
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TextField("Type a message...", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(true)
            }
            .padding()
        }
    }
}

// MARK: - Group Sessions View
struct GroupSessionsView: View {
    let groupId: String
    @State private var showScheduleSheet = false
    
    var body: some View {
        VStack {
            List {
                Text("Upcoming study sessions will appear here")
                    .foregroundColor(.secondary)
            }
            
            Button(action: { showScheduleSheet = true }) {
                Label("Schedule Session", systemImage: "calendar.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .sheet(isPresented: $showScheduleSheet) {
            NavigationStack {
                Text("Schedule Session View")
                    .navigationTitle("Schedule Session")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showScheduleSheet = false
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Group Members View
struct GroupMembersView: View {
    let group: StudyGroup
    let currentUserId: String
    let collegeId: String
    let searchUsersUseCase: SearchUsersUseCase?
    let inviteUserToGroupUseCase: InviteUserToGroupUseCase?
    let leaveStudyGroupUseCase: LeaveStudyGroupUseCase?
    let deleteStudyGroupUseCase: DeleteStudyGroupUseCase?
    @Binding var showLeaveConfirmation: Bool
    
    @State private var showUserSearch = false
    
    init(group: StudyGroup, currentUserId: String, collegeId: String, 
         searchUsersUseCase: SearchUsersUseCase?, inviteUserToGroupUseCase: InviteUserToGroupUseCase?,
         leaveStudyGroupUseCase: LeaveStudyGroupUseCase?, deleteStudyGroupUseCase: DeleteStudyGroupUseCase?,
         showLeaveConfirmation: Binding<Bool>) {
        self.group = group
        self.currentUserId = currentUserId
        self.collegeId = collegeId
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        self.leaveStudyGroupUseCase = leaveStudyGroupUseCase
        self.deleteStudyGroupUseCase = deleteStudyGroupUseCase
        self._showLeaveConfirmation = showLeaveConfirmation
        
        print("👥 GroupMembersView INIT")
        print("   Group: \(group.name)")
        print("   Members: \(group.memberIds.count)")
        print("   Is member: \(group.memberIds.contains(currentUserId))")
        print("   Search Use Case: \(searchUsersUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Invite Use Case: \(inviteUserToGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Label("Members", systemImage: "person.2")
                    Spacer()
                    Text("\(group.memberIds.count)")
                        .foregroundColor(.secondary)
                }
                
                if let max = group.maxMembers {
                    HStack {
                        Label("Max Members", systemImage: "person.3")
                        Spacer()
                        Text("\(max)")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label("Type", systemImage: group.isPublic ? "globe" : "lock.fill")
                    Spacer()
                    Text(group.isPublic ? "Public" : "Private")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Info") {
                if let description = group.description {
                    Text(description)
                        .foregroundColor(.secondary)
                } else {
                    Text("No description")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            // Members List
            Section("Members (\(group.memberIds.count))") {
                ForEach(group.memberIds, id: \.self) { memberId in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        
                        if memberId == group.createdBy {
                            Text("Creator")
                                .font(.subheadline)
                        } else {
                            Text("Member")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        if memberId == currentUserId {
                            Text("You")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Debug section - ALWAYS VISIBLE
            Section(header: Text("DEBUG INFO")) {
                Text("Current User: \(currentUserId)")
                Text("Is Member: \(group.memberIds.contains(currentUserId) ? "YES" : "NO")")
                Text("Search Use Case: \(searchUsersUseCase != nil ? "Available" : "NIL")")
                Text("Invite Use Case: \(inviteUserToGroupUseCase != nil ? "Available" : "NIL")")
            }
            
            // Add Member button - show for group members
            Section(header: Text("Manage Members")) {
                Button(action: { 
                    if searchUsersUseCase != nil && inviteUserToGroupUseCase != nil {
                        showUserSearch = true 
                    }
                }) {
                    Label("Add Member", systemImage: "person.badge.plus")
                }
                .disabled(searchUsersUseCase == nil || inviteUserToGroupUseCase == nil)
            }
            
            Section {
                Button("Leave Group", role: .destructive) {
                    print("🚪 Leave Group button tapped from section")
                    showLeaveConfirmation = true
                }
            }
        }
        .sheet(isPresented: $showUserSearch) {
            AddMemberView(
                group: group,
                currentUserId: currentUserId,
                collegeId: collegeId,
                searchUsersUseCase: searchUsersUseCase,
                inviteUserToGroupUseCase: inviteUserToGroupUseCase
            )
        }
    }
}
