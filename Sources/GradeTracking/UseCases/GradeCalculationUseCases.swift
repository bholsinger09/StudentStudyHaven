import Core
import Foundation

public class CalculateClassGradeUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(classId: String) async throws -> CourseGradeInfo {
        let assignments = try await assignmentRepository.getAssignments(for: classId)
        return CourseGradeInfo(classId: classId, assignments: assignments)
    }
}

public class CalculateGPAUseCase {
    private let classRepository: ClassRepositoryProtocol
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(
        classRepository: ClassRepositoryProtocol,
        assignmentRepository: AssignmentRepositoryProtocol
    ) {
        self.classRepository = classRepository
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(userId: String, scale: GPAScale = .scale4) async throws -> Double {
        let classes = try await classRepository.getClasses(for: userId)
        
        var totalGPA: Double = 0
        var classCount = 0
        
        for classItem in classes {
            let assignments = try await assignmentRepository.getAssignments(for: classItem.id)
            let courseGrade = CourseGradeInfo(classId: classItem.id, assignments: assignments)
            
            let scaledGPA = scale == .scale4 ? courseGrade.gpa : (courseGrade.gpa / 4.0) * 5.0
            totalGPA += scaledGPA
            classCount += 1
        }
        
        guard classCount > 0 else { return 0 }
        
        let averageGPA = totalGPA / Double(classCount)
        return min(4.0 * (scale == .scale4 ? 1 : 1.25), averageGPA)
    }
}

public class CalculateRequiredScoreUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(
        classId: String,
        targetPercentage: Double
    ) async throws -> Double? {
        guard targetPercentage >= 0 && targetPercentage <= 100 else {
            throw ValidationError.invalidScore
        }
        
        let assignments = try await assignmentRepository.getAssignments(for: classId)
        let courseGrade = CourseGradeInfo(classId: classId, assignments: assignments)
        
        return courseGrade.requiredScoreForTarget(targetPercentage)
    }
}

public class GetGradeAnalyticsUseCase {
    private let classRepository: ClassRepositoryProtocol
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(
        classRepository: ClassRepositoryProtocol,
        assignmentRepository: AssignmentRepositoryProtocol
    ) {
        self.classRepository = classRepository
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(userId: String) async throws -> GradeAnalytics {
        let classes = try await classRepository.getClasses(for: userId)
        
        var courseGrades: [CourseGradeInfo] = []
        var allAssignments: [Assignment] = []
        
        for classItem in classes {
            let assignments = try await assignmentRepository.getAssignments(for: classItem.id)
            allAssignments.append(contentsOf: assignments)
            courseGrades.append(CourseGradeInfo(classId: classItem.id, assignments: assignments))
        }
        
        // Calculate statistics
        let grades = courseGrades.map { $0.currentGrade }
        let averageGrade = grades.isEmpty ? 0 : grades.reduce(0, +) / Double(grades.count)
        let highestGrade = grades.max() ?? 0
        let lowestGrade = grades.min() ?? 0
        
        // Grade distribution
        let aCount = grades.filter { $0 >= 90 }.count
        let bCount = grades.filter { $0 >= 80 && $0 < 90 }.count
        let cCount = grades.filter { $0 >= 70 && $0 < 80 }.count
        let dCount = grades.filter { $0 >= 60 && $0 < 70 }.count
        let fCount = grades.filter { $0 < 60 }.count
        
        return GradeAnalytics(
            averageGrade: averageGrade,
            highestGrade: highestGrade,
            lowestGrade: lowestGrade,
            totalClasses: courseGrades.count,
            totalAssignments: allAssignments.count,
            completedAssignments: allAssignments.filter { $0.isSubmitted }.count,
            gradeDistribution: GradeDistribution(
                aCount: aCount,
                bCount: bCount,
                cCount: cCount,
                dCount: dCount,
                fCount: fCount
            )
        )
    }
}

public struct GradeAnalytics: Equatable {
    public let averageGrade: Double
    public let highestGrade: Double
    public let lowestGrade: Double
    public let totalClasses: Int
    public let totalAssignments: Int
    public let completedAssignments: Int
    public let gradeDistribution: GradeDistribution
    
    public init(
        averageGrade: Double,
        highestGrade: Double,
        lowestGrade: Double,
        totalClasses: Int,
        totalAssignments: Int,
        completedAssignments: Int,
        gradeDistribution: GradeDistribution
    ) {
        self.averageGrade = averageGrade
        self.highestGrade = highestGrade
        self.lowestGrade = lowestGrade
        self.totalClasses = totalClasses
        self.totalAssignments = totalAssignments
        self.completedAssignments = completedAssignments
        self.gradeDistribution = gradeDistribution
    }
    
    public var completionPercentage: Double {
        guard totalAssignments > 0 else { return 0 }
        return (Double(completedAssignments) / Double(totalAssignments)) * 100
    }
}

public struct GradeDistribution: Equatable {
    public let aCount: Int
    public let bCount: Int
    public let cCount: Int
    public let dCount: Int
    public let fCount: Int
    
    public init(aCount: Int, bCount: Int, cCount: Int, dCount: Int, fCount: Int) {
        self.aCount = aCount
        self.bCount = bCount
        self.cCount = cCount
        self.dCount = dCount
        self.fCount = fCount
    }
    
    public var total: Int {
        aCount + bCount + cCount + dCount + fCount
    }
}

public enum GPAScale {
    case scale4
    case scale5
}
