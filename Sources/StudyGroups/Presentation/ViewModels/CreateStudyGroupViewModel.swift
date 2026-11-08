import Combine
import Core
import Foundation

/// ViewModel for creating a new Study Group
@MainActor
public final class CreateStudyGroupViewModel: ObservableObject {
    @Published public var name: String = ""
    @Published public var description: String = ""
    @Published public var selectedClassId: String = ""
    @Published public var maxMembers: String = ""
    @Published public var isPublic: Bool = true
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let createStudyGroupUseCase: CreateStudyGroupUseCase
    private let userId: String
    private let collegeId: String
    
    public var onGroupCreated: ((StudyGroup) -> Void)?
    
    public init(
        createStudyGroupUseCase: CreateStudyGroupUseCase,
        userId: String,
        collegeId: String
    ) {
        self.createStudyGroupUseCase = createStudyGroupUseCase
        self.userId = userId
        self.collegeId = collegeId
    }
    
    public var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedClassId.isEmpty
    }
    
    public func createGroup() async -> Bool {
        guard isValid else {
            errorMessage = "Please fill in all required fields"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let maxMembersInt = maxMembers.isEmpty ? nil : Int(maxMembers)
            
            let group = try await createStudyGroupUseCase.execute(
                name: name,
                classId: selectedClassId,
                collegeId: collegeId,
                description: description.isEmpty ? nil : description,
                createdBy: userId,
                maxMembers: maxMembersInt,
                isPublic: isPublic
            )
            
            onGroupCreated?(group)
            isLoading = false
            return true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        } catch let error as NSError {
            // Provide specific error messages for CloudKit errors
            if error.domain == "CKErrorDomain" {
                if error.code == 1 { // CKError.notAuthenticated
                    errorMessage = "Please sign in to iCloud in Settings"
                } else if error.code == 25 { // CKError.requestRateLimited
                    errorMessage = "Too many requests. Please try again later"
                } else {
                    errorMessage = "CloudKit error: \(error.localizedDescription)"
                }
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to create study group: \(error)"
            isLoading = false
            return false
        }
    }
    
    public func reset() {
        name = ""
        description = ""
        selectedClassId = ""
        maxMembers = ""
        isPublic = true
        errorMessage = nil
    }
}
