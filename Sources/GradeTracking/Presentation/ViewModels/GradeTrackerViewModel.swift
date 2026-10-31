import Combine
import Core
import Foundation

@MainActor
public class GradeTrackerViewModel: ObservableObject {
    @Published public var courseGrades: [CourseGradeInfo] = []
    @Published public var overallGPA: Double = 0.0
    @Published public var isLoading = false
    @Published public var error: String?
    @Published public var classes: [Class] = []
    @Published public var allAssignments: [Assignment] = []
    
    private let calculateGPAUseCase: CalculateGPAUseCase
    private let calculateClassGradeUseCase: CalculateClassGradeUseCase
    private let getGradeAnalyticsUseCase: GetGradeAnalyticsUseCase
    public let classRepository: ClassRepositoryProtocol
    public let assignmentRepository: AssignmentRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public let userId: String
    
    public init(
        calculateGPAUseCase: CalculateGPAUseCase,
        calculateClassGradeUseCase: CalculateClassGradeUseCase,
        getGradeAnalyticsUseCase: GetGradeAnalyticsUseCase,
        classRepository: ClassRepositoryProtocol,
        assignmentRepository: AssignmentRepositoryProtocol,
        userId: String
    ) {
        self.calculateGPAUseCase = calculateGPAUseCase
        self.calculateClassGradeUseCase = calculateClassGradeUseCase
        self.getGradeAnalyticsUseCase = getGradeAnalyticsUseCase
        self.classRepository = classRepository
        self.assignmentRepository = assignmentRepository
        self.userId = userId
    }
    
    public func loadGrades() async {
        isLoading = true
        error = nil
        
        do {
            // Load classes
            let classes = try await classRepository.getClasses(for: userId)
            
            // Load all assignments
            var allAssignments: [Assignment] = []
            for classItem in classes {
                let classAssignments = try await GetAssignmentsForClassUseCase(
                    assignmentRepository: assignmentRepository
                ).execute(classId: classItem.id)
                allAssignments.append(contentsOf: classAssignments)
            }
            
            await MainActor.run {
                self.classes = classes
                self.allAssignments = allAssignments
            }
            
            // Load grades for each class
            var grades: [CourseGradeInfo] = []
            for classItem in classes {
                let grade = try await calculateClassGradeUseCase.execute(classId: classItem.id)
                grades.append(grade)
            }
            
            // Calculate GPA
            let gpa = try await calculateGPAUseCase.execute(userId: userId)
            
            await MainActor.run {
                self.courseGrades = grades
                self.overallGPA = gpa
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    public func deleteAssignment(_ assignmentId: String) async {
        let deleteUseCase = DeleteAssignmentUseCase(assignmentRepository: assignmentRepository)
        
        do {
            try await deleteUseCase.execute(assignmentId: assignmentId)
            await loadGrades()
        } catch {
            await MainActor.run {
                self.error = "Failed to delete assignment: \(error.localizedDescription)"
            }
        }
    }
    
    public func getCourseGrade(for classId: String) -> CourseGradeInfo? {
        courseGrades.first { $0.id == classId }
    }
}
