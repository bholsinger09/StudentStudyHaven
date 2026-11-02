import Foundation

public struct CourseGradeInfo: Identifiable, Codable, Equatable {
    public let classId: String
    public let assignments: [Assignment]
    
    public init(classId: String, assignments: [Assignment] = []) {
        self.classId = classId
        self.assignments = assignments
    }
    
    public var currentGrade: Double {
        let completedAssignments = assignments.filter { $0.isSubmitted }
        
        guard !completedAssignments.isEmpty else { return 0 }
        
        let totalWeight = completedAssignments.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        let weightedSum = completedAssignments.reduce(0) { total, assignment in
            let percentage = assignment.scorePercentage ?? 0
            return total + (percentage * assignment.weight)
        }
        
        return weightedSum / totalWeight
    }
    
    public var letterGrade: String {
        let grade = currentGrade
        
        if grade >= 90 {
            return "A"
        } else if grade >= 80 {
            return "B"
        } else if grade >= 70 {
            return "C"
        } else if grade >= 60 {
            return "D"
        } else {
            return "F"
        }
    }
    
    public var gpa: Double {
        let grade = currentGrade
        
        if grade >= 93 { return 4.0 }
        else if grade >= 90 { return 3.7 }
        else if grade >= 87 { return 3.3 }
        else if grade >= 83 { return 3.0 }
        else if grade >= 80 { return 2.7 }
        else if grade >= 77 { return 2.3 }
        else if grade >= 73 { return 2.0 }
        else if grade >= 70 { return 1.7 }
        else if grade >= 67 { return 1.3 }
        else if grade >= 60 { return 1.0 }
        else { return 0.0 }
    }
    
    public func requiredScoreForTarget(_ targetPercentage: Double) -> Double? {
        let pendingAssignments = assignments.filter { !$0.isSubmitted }
        let completedAssignments = assignments.filter { $0.isSubmitted }
        
        guard !pendingAssignments.isEmpty else { return nil }
        
        let pendingWeight = pendingAssignments.reduce(0) { $0 + $1.weight }
        let completedWeight = completedAssignments.reduce(0) { $0 + $1.weight }
        
        guard pendingWeight > 0 else { return nil }
        
        let currentWeightedPoints = completedAssignments.reduce(0) { total, assignment in
            let percentage = assignment.scorePercentage ?? 0
            return total + (percentage * assignment.weight)
        }
        
        let requiredWeightedPoints = (targetPercentage * (completedWeight + pendingWeight)) - currentWeightedPoints
        let requiredAverage = requiredWeightedPoints / pendingWeight
        
        return max(0, min(100, requiredAverage))
    }
    
    public var completionPercentage: Double {
        guard !assignments.isEmpty else { return 0 }
        let completed = Double(assignments.filter { $0.isSubmitted }.count)
        return (completed / Double(assignments.count)) * 100
    }
    
    public var id: String {
        classId
    }
}
