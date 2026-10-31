import Core
import Foundation

@MainActor
public class AddAssignmentViewModel: ObservableObject {
    @Published public var classes: [Class] = []
    @Published public var selectedClassId: String?
    @Published public var name: String = ""
    @Published public var dueDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
    @Published public var score: String = ""
    @Published public var maxScore: String = "100"
    @Published public var weight: String = "10"
    @Published public var type: AssignmentType = .homework
    @Published public var description: String = ""
    @Published public var error: String?
    @Published public var isLoading = false
    @Published public var isLoadingClasses = false
    @Published public var isFormValid = false
    
    private let addAssignmentUseCase: AddAssignmentUseCase
    private let classRepository: ClassRepositoryProtocol
    private let userId: String
    
    public var selectedClass: Class? {
        guard let classId = selectedClassId else { return nil }
        return classes.first { $0.id == classId }
    }
    
    public init(
        addAssignmentUseCase: AddAssignmentUseCase,
        classRepository: ClassRepositoryProtocol,
        userId: String
    ) {
        self.addAssignmentUseCase = addAssignmentUseCase
        self.classRepository = classRepository
        self.userId = userId
        
        validateForm()
    }
    
    public func loadClasses() async {
        isLoadingClasses = true
        error = nil
        
        do {
            let loadedClasses = try await classRepository.getClasses(for: userId)
            await MainActor.run {
                self.classes = loadedClasses
                if let firstClass = loadedClasses.first {
                    self.selectedClassId = firstClass.id
                }
                self.isLoadingClasses = false
                self.validateForm()
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load classes: \(error.localizedDescription)"
                self.isLoadingClasses = false
            }
        }
    }
    
    public func saveAssignment() async throws -> Assignment {
        validateForm()
        
        guard isFormValid else {
            throw ValidationError.emptyName
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        let weightDouble = Double(weight) ?? 10
        let maxScoreDouble = Double(maxScore) ?? 100
        
        guard let classId = selectedClassId else {
            throw ValidationError.emptyName
        }
        
        let description = self.description.isEmpty ? nil : self.description
        
        let assignment = try await addAssignmentUseCase.execute(
            classId: classId,
            name: name,
            dueDate: dueDate,
            weight: weightDouble,
            maxScore: maxScoreDouble,
            type: type,
            description: description
        )
        
        // Reset form
        resetForm()
        
        return assignment
    }
    
    public func validateForm() {
        let isNameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let isWeightValid = (Double(weight) ?? 0) > 0 && (Double(weight) ?? 0) <= 100
        let isMaxScoreValid = (Double(maxScore) ?? 0) > 0
        let isClassSelected = selectedClassId != nil
        
        isFormValid = isNameValid && isWeightValid && isMaxScoreValid && isClassSelected
    }
    
    private func resetForm() {
        name = ""
        dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        score = ""
        maxScore = "100"
        weight = "10"
        type = .homework
        description = ""
        error = nil
        validateForm()
    }
}
