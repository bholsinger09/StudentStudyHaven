import Core
import Foundation

@MainActor
public class ClassDetailGradesViewModel: ObservableObject {
    @Published public var assignments: [Assignment] = []
    @Published public var currentGrade: Double = 0.0
    @Published public var letterGrade: String = "N/A"
    @Published public var requiredScoreForA: Double?
    @Published public var isLoading = false
    @Published public var error: String?
    @Published public var showDeleteConfirm = false
    @Published public var assignmentToDelete: Assignment?
    
    private let calculateClassGradeUseCase: CalculateClassGradeUseCase
    private let getAssignmentsForClassUseCase: GetAssignmentsForClassUseCase
    private let calculateRequiredScoreUseCase: CalculateRequiredScoreUseCase
    private let deleteAssignmentUseCase: DeleteAssignmentUseCase
    
    public let classId: String
    public let className: String
    
    public init(
        classId: String,
        className: String,
        calculateClassGradeUseCase: CalculateClassGradeUseCase,
        getAssignmentsForClassUseCase: GetAssignmentsForClassUseCase,
        calculateRequiredScoreUseCase: CalculateRequiredScoreUseCase,
        deleteAssignmentUseCase: DeleteAssignmentUseCase
    ) {
        self.classId = classId
        self.className = className
        self.calculateClassGradeUseCase = calculateClassGradeUseCase
        self.getAssignmentsForClassUseCase = getAssignmentsForClassUseCase
        self.calculateRequiredScoreUseCase = calculateRequiredScoreUseCase
        self.deleteAssignmentUseCase = deleteAssignmentUseCase
    }
    
    public func loadGrades() async {
        isLoading = true
        error = nil
        
        do {
            // Load assignments
            let assignments = try await getAssignmentsForClassUseCase.execute(classId: classId)
            
            // Calculate grade
            let courseGrade = try await calculateClassGradeUseCase.execute(classId: classId)
            
            // Calculate required score for A
            let requiredForA = try await calculateRequiredScoreUseCase.execute(
                classId: classId,
                targetPercentage: 90
            )
            
            await MainActor.run {
                self.assignments = assignments
                self.currentGrade = courseGrade.currentGrade
                self.letterGrade = courseGrade.letterGrade
                self.requiredScoreForA = requiredForA
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    public func deleteAssignment(_ assignment: Assignment) async {
        do {
            try await deleteAssignmentUseCase.execute(assignmentId: assignment.id)
            await loadGrades()
        } catch {
            await MainActor.run {
                self.error = "Failed to delete assignment: \(error.localizedDescription)"
            }
        }
    }
    
    public func calculateRequiredScore(for targetGrade: Double) async {
        do {
            let required = try await calculateRequiredScoreUseCase.execute(
                classId: classId,
                targetPercentage: targetGrade
            )
            
            await MainActor.run {
                self.requiredScoreForA = required
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to calculate required score: \(error.localizedDescription)"
            }
        }
    }
    
    public var completionPercentage: Double {
        guard !assignments.isEmpty else { return 0 }
        let completed = Double(assignments.filter { $0.isSubmitted }.count)
        return (completed / Double(assignments.count)) * 100
    }
}
