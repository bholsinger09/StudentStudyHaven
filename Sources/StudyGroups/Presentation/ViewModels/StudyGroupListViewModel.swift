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
    private let userId: String
    private let collegeId: String
    
    public init(
        getStudyGroupsUseCase: GetStudyGroupsUseCase,
        joinStudyGroupUseCase: JoinStudyGroupUseCase,
        userId: String,
        collegeId: String
    ) {
        self.getStudyGroupsUseCase = getStudyGroupsUseCase
        self.joinStudyGroupUseCase = joinStudyGroupUseCase
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
}
