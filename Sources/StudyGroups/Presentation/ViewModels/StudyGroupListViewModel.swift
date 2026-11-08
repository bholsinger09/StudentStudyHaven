import Combine
import Core
import Foundation

/// ViewModel for Study Groups List screen
@MainActor
public final class StudyGroupListViewModel: ObservableObject {
    @Published public var myGroups: [StudyGroup] = []
    @Published public var discoverGroups: [StudyGroup] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showCreateSheet: Bool = false
    
    private let getStudyGroupsUseCase: GetStudyGroupsUseCase
    private let joinStudyGroupUseCase: JoinStudyGroupUseCase
    private let leaveStudyGroupUseCase: LeaveStudyGroupUseCase
    private let deleteStudyGroupUseCase: DeleteStudyGroupUseCase
    let studyGroupRepository: StudyGroupRepositoryProtocol
    private let userId: String
    private let collegeId: String
    
    public init(
        getStudyGroupsUseCase: GetStudyGroupsUseCase,
        joinStudyGroupUseCase: JoinStudyGroupUseCase,
        leaveStudyGroupUseCase: LeaveStudyGroupUseCase,
        deleteStudyGroupUseCase: DeleteStudyGroupUseCase,
        studyGroupRepository: StudyGroupRepositoryProtocol,
        userId: String,
        collegeId: String
    ) {
        self.getStudyGroupsUseCase = getStudyGroupsUseCase
        self.joinStudyGroupUseCase = joinStudyGroupUseCase
        self.leaveStudyGroupUseCase = leaveStudyGroupUseCase
        self.deleteStudyGroupUseCase = deleteStudyGroupUseCase
        self.studyGroupRepository = studyGroupRepository
        self.userId = userId
        self.collegeId = collegeId
    }
    
    public func loadMyGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            myGroups = try await getStudyGroupsUseCase.execute(for: userId)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load study groups"
        }
        
        isLoading = false
    }
    
    public func loadDiscoverGroups(classId: String? = nil) async {
        do {
            // Use provided collegeId or default to "Boise State University" for testing
            let finalCollegeId = collegeId.isEmpty ? "Boise State University" : collegeId
            print("DEBUG StudyGroupListViewModel.loadDiscoverGroups() - collegeId: '\(collegeId)' -> finalCollegeId: '\(finalCollegeId)'")
            
            discoverGroups = try await getStudyGroupsUseCase.executeForDiscovery(
                collegeId: finalCollegeId,
                classId: classId
            )
            // Filter out groups user is already in
            discoverGroups = discoverGroups.filter { group in
                !myGroups.contains(where: { $0.id == group.id })
            }
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load available groups"
        }
    }
    
    public func joinGroup(_ group: StudyGroup) async {
        do {
            let updatedGroup = try await joinStudyGroupUseCase.execute(
                groupId: group.id,
                userId: userId
            )
            // Move from discover to my groups
            discoverGroups.removeAll { $0.id == group.id }
            myGroups.append(updatedGroup)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to join group"
        }
    }
    
    public func joinGroupByQRCode(groupId: String, userId: String) async {
        print("🔗 StudyGroupListViewModel.joinGroupByQRCode() - Starting join for groupId: '\(groupId)', userId: '\(userId)'")
        do {
            print("🔗 StudyGroupListViewModel: Calling joinStudyGroupUseCase.execute()")
            let updatedGroup = try await joinStudyGroupUseCase.execute(
                groupId: groupId,
                userId: userId
            )
            print("✅ StudyGroupListViewModel: Join succeeded! Group: \(updatedGroup.name)")
            
            // Add to my groups
            if !myGroups.contains(where: { $0.id == groupId }) {
                myGroups.append(updatedGroup)
                print("✅ StudyGroupListViewModel: Added group to myGroups. Total groups: \(myGroups.count)")
            } else {
                print("⚠️ StudyGroupListViewModel: Group already in myGroups")
            }
            
            // Remove from discover if it's there
            if discoverGroups.contains(where: { $0.id == groupId }) {
                discoverGroups.removeAll { $0.id == groupId }
                print("✅ StudyGroupListViewModel: Removed group from discoverGroups")
            }
            
            errorMessage = nil
            print("✅ StudyGroupListViewModel: Join complete!")
        } catch let error as AppError {
            print("❌ StudyGroupListViewModel: Join failed with AppError: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            print("❌ StudyGroupListViewModel: Join failed with error: \(error)")
            errorMessage = "Failed to join group"
        }
    }
    
    public func leaveGroup(groupId: String) async {
        print("🚪 StudyGroupListViewModel.leaveGroup() - Leaving group: \(groupId)")
        do {
            _ = try await leaveStudyGroupUseCase.execute(groupId: groupId, userId: userId)
            myGroups.removeAll { $0.id == groupId }
            errorMessage = nil
            print("✅ StudyGroupListViewModel: Left group successfully")
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            print("❌ StudyGroupListViewModel: Leave failed - \(error.localizedDescription)")
        } catch {
            errorMessage = "Failed to leave group"
            print("❌ StudyGroupListViewModel: Leave failed - \(error)")
        }
    }
    
    public func deleteGroup(groupId: String) async {
        print("🗑️ StudyGroupListViewModel.deleteGroup() - Deleting group: \(groupId)")
        do {
            try await deleteStudyGroupUseCase.execute(groupId: groupId, userId: userId)
            myGroups.removeAll { $0.id == groupId }
            discoverGroups.removeAll { $0.id == groupId }
            errorMessage = nil
            print("✅ StudyGroupListViewModel: Deleted group successfully")
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            print("❌ StudyGroupListViewModel: Delete failed - \(error.localizedDescription)")
        } catch {
            errorMessage = "Failed to delete group"
            print("❌ StudyGroupListViewModel: Delete failed - \(error)")
        }
    }
}
