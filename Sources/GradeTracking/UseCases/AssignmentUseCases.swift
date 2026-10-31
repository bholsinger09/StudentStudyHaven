import Core
import Foundation

public class AddAssignmentUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(
        classId: String,
        name: String,
        dueDate: Date,
        weight: Double,
        maxScore: Double = 100,
        type: AssignmentType = .homework,
        description: String? = nil
    ) async throws -> Assignment {
        // Validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyName
        }
        
        guard weight > 0 && weight <= 100 else {
            throw ValidationError.invalidWeight
        }
        
        guard maxScore > 0 else {
            throw ValidationError.invalidMaxScore
        }
        
        let assignment = Assignment(
            classId: classId,
            name: name,
            dueDate: dueDate,
            description: description,
            maxScore: maxScore,
            weight: weight,
            type: type
        )
        
        return try await assignmentRepository.createAssignment(assignment)
    }
}

public class UpdateAssignmentScoreUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(
        assignmentId: String,
        score: Double?,
        type: AssignmentType? = nil
    ) async throws -> Assignment {
        var assignment = try await assignmentRepository.getAssignment(by: assignmentId)
        
        if let score = score {
            guard score >= 0 && score <= assignment.maxScore else {
                throw ValidationError.invalidScore
            }
            assignment.score = score
        }
        
        if let type = type {
            assignment.type = type
        }
        
        assignment.updatedAt = Date()
        
        return try await assignmentRepository.updateAssignment(assignment)
    }
}

public class GetAssignmentsForClassUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(classId: String) async throws -> [Assignment] {
        let assignments = try await assignmentRepository.getAssignments(for: classId)
        return assignments.sorted { $0.dueDate < $1.dueDate }
    }
}

public class GetUpcomingAssignmentsUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(daysAhead: Int = 7) async throws -> [Assignment] {
        let assignments = try await assignmentRepository.getUpcomingAssignments(daysAhead: daysAhead)
        return assignments.sorted { $0.dueDate < $1.dueDate }
    }
}

public class DeleteAssignmentUseCase {
    private let assignmentRepository: AssignmentRepositoryProtocol
    
    public init(assignmentRepository: AssignmentRepositoryProtocol) {
        self.assignmentRepository = assignmentRepository
    }
    
    public func execute(assignmentId: String) async throws {
        try await assignmentRepository.deleteAssignment(id: assignmentId)
    }
}

public enum ValidationError: LocalizedError {
    case emptyName
    case invalidWeight
    case invalidMaxScore
    case invalidScore
    
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Assignment name cannot be empty"
        case .invalidWeight:
            return "Weight must be between 0 and 100"
        case .invalidMaxScore:
            return "Max score must be greater than 0"
        case .invalidScore:
            return "Score cannot exceed max score"
        }
    }
}
