import Core
import SwiftUI

/// Study Group Detail View
public struct StudyGroupDetailView: View {
    let groupId: String
    let studyGroup: StudyGroup
    let currentUserId: String
    let collegeId: String
    let searchUsersUseCase: SearchUsersUseCase?
    let inviteUserToGroupUseCase: InviteUserToGroupUseCase?
    
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    public init(
        groupId: String,
        studyGroup: StudyGroup,
        currentUserId: String,
        collegeId: String,
        searchUsersUseCase: SearchUsersUseCase? = nil,
        inviteUserToGroupUseCase: InviteUserToGroupUseCase? = nil
    ) {
        self.groupId = groupId
        self.studyGroup = studyGroup
        self.currentUserId = currentUserId
        self.collegeId = collegeId
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        
        print("🔍 StudyGroupDetailView INIT")
        print("   Group: \(studyGroup.name)")
        print("   Current User: \(currentUserId)")
        print("   Search Use Case: \(searchUsersUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
        print("   Invite Use Case: \(inviteUserToGroupUseCase != nil ? "✅ PRESENT" : "❌ NIL")")
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
                    inviteUserToGroupUseCase: inviteUserToGroupUseCase
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
    
    @State private var showUserSearch = false
    
    init(group: StudyGroup, currentUserId: String, collegeId: String, 
         searchUsersUseCase: SearchUsersUseCase?, inviteUserToGroupUseCase: InviteUserToGroupUseCase?) {
        self.group = group
        self.currentUserId = currentUserId
        self.collegeId = collegeId
        self.searchUsersUseCase = searchUsersUseCase
        self.inviteUserToGroupUseCase = inviteUserToGroupUseCase
        
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
                    // Handle leave
                }
            }
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
