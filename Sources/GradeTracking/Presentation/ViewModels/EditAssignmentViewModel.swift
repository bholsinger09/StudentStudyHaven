import Core
import Foundation

public enum EditMode {
    case create
    case edit(Assignment)
}

// Grade presets for quick selection
public struct GradeOption: Identifiable, Hashable {
    public let id: String
    public let label: String
    public let percentage: Double?
    
    static let options = [
        GradeOption(id: "not-graded", label: "Not graded", percentage: nil),
        GradeOption(id: "not-turned-in", label: "Not turned in", percentage: 0),
        GradeOption(id: "50", label: "50%", percentage: 50),
        GradeOption(id: "60", label: "60%", percentage: 60),
        GradeOption(id: "70", label: "70%", percentage: 70),
        GradeOption(id: "80", label: "80%", percentage: 80),
        GradeOption(id: "85", label: "85%", percentage: 85),
        GradeOption(id: "90", label: "90%", percentage: 90),
        GradeOption(id: "95", label: "95%", percentage: 95),
        GradeOption(id: "100", label: "100%", percentage: 100),
    ]
}

@MainActor
public class EditAssignmentViewModel: ObservableObject {
    @Published public var name: String = ""
    @Published public var description: String = ""
    @Published public var dueDate: Date = Date()
    @Published public var score: String = ""
    @Published public var maxScore: String = "100"
    @Published public var weight: String = "1"
    @Published public var type: AssignmentType = .homework
    @Published public var selectedClassId: String = ""
    @Published public var classes: [Class] = []
    @Published public var isLoadingClasses = false
    @Published public var error: String?
    @Published public var isFormValid = false
    @Published public var selectedGrade: GradeOption = GradeOption.options[0]
    
    private let editAssignmentUseCase: UpdateAssignmentScoreUseCase
    private let addAssignmentUseCase: AddAssignmentUseCase
    private let classRepository: ClassRepositoryProtocol
    private let userId: String
    private let mode: EditMode
    
    private var editingAssignment: Assignment?
    
    public var isCreating: Bool {
        if case .create = mode {
            return true
        }
        return false
    }
    
    public var scorePercentage: Double? {
        guard let scoreVal = Double(score),
              let maxVal = Double(maxScore),
              maxVal > 0 else {
            return nil
        }
        return (scoreVal / maxVal) * 100
    }
    
    public init(
        editAssignmentUseCase: UpdateAssignmentScoreUseCase,
        addAssignmentUseCase: AddAssignmentUseCase,
        classRepository: ClassRepositoryProtocol,
        userId: String,
        mode: EditMode
    ) {
        self.editAssignmentUseCase = editAssignmentUseCase
        self.addAssignmentUseCase = addAssignmentUseCase
        self.classRepository = classRepository
        self.userId = userId
        self.mode = mode
        
        // If editing, populate fields
        if case .edit(let assignment) = mode {
            self.editingAssignment = assignment
            self.name = assignment.name
            self.description = assignment.description ?? ""
            self.dueDate = assignment.dueDate
            self.score = assignment.score.map { String(format: "%.0f", $0) } ?? ""
            self.maxScore = String(format: "%.0f", assignment.maxScore)
            self.weight = String(format: "%.0f", assignment.weight)
            self.type = assignment.type
            self.selectedClassId = assignment.classId
            
            // Set selectedGrade based on score
            if let scoreVal = assignment.score {
                let percentage = (scoreVal / assignment.maxScore) * 100
                if let matchingGrade = GradeOption.options.first(where: { $0.percentage == percentage }) {
                    self.selectedGrade = matchingGrade
                }
            }
        }
    }
    
    public func loadClasses() async {
        isLoadingClasses = true
        do {
            let loadedClasses = try await classRepository.getClasses(for: userId)
            self.classes = loadedClasses
            
            // Auto-select first class if not already set
            if selectedClassId.isEmpty && !loadedClasses.isEmpty {
                selectedClassId = loadedClasses[0].id
            }
        } catch {
            self.error = "Failed to load classes: \(error.localizedDescription)"
        }
        isLoadingClasses = false
    }
    
    public func validateForm() {
        error = nil
        
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        let hasClass = !selectedClassId.isEmpty
        let hasMaxScore = !maxScore.trimmingCharacters(in: .whitespaces).isEmpty
        let hasWeight = !weight.trimmingCharacters(in: .whitespaces).isEmpty
        
        // When editing, allow updates if score or type has changed
        if !isCreating {
            guard let originalAssignment = editingAssignment else {
                isFormValid = false
                return
            }
            
            let scoreChanged = !score.trimmingCharacters(in: .whitespaces).isEmpty
            let typeChanged = type != originalAssignment.type
            
            // Allow update if score was entered OR type was changed
            isFormValid = scoreChanged || typeChanged
            return
        }
        
        // For creating, need all fields
        isFormValid = hasName && hasClass && hasMaxScore && hasWeight
    }
    
    public func save() async throws {
        if isCreating {
            try await createAssignment()
        } else {
            try await updateAssignment()
        }
    }
    
    private func createAssignment() async throws {
        validateForm()
        
        guard isFormValid else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please fill in all required fields"])
        }
        
        guard let maxScoreVal = Double(maxScore) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Max points must be a number"])
        }
        
        guard let weightVal = Double(weight) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Weight must be a number"])
        }
        
        _ = try await addAssignmentUseCase.execute(
            classId: selectedClassId,
            name: name,
            dueDate: dueDate,
            weight: weightVal,
            maxScore: maxScoreVal,
            type: type,
            description: description.isEmpty ? nil : description
        )
    }
    
    private func updateAssignment() async throws {
        guard let assignment = editingAssignment else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No assignment to update"])
        }
        
        // Score is optional when editing - user might just be changing the type
        let scoreVal = !score.trimmingCharacters(in: .whitespaces).isEmpty ? Double(score) : nil
        
        if scoreVal == nil && score != "" {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Score must be a valid number"])
        }
        
        _ = try await editAssignmentUseCase.execute(
            assignmentId: assignment.id,
            score: scoreVal,
            type: type
        )
    }
}
