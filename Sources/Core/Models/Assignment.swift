import Foundation

public struct Assignment: Identifiable, Codable, Equatable {
    public let id: String
    public let classId: String
    public let name: String
    public let dueDate: Date
    public let description: String?
    public var score: Double?
    public let maxScore: Double
    public let weight: Double
    public var type: AssignmentType
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        classId: String,
        name: String,
        dueDate: Date,
        description: String? = nil,
        score: Double? = nil,
        maxScore: Double = 100,
        weight: Double,
        type: AssignmentType = .homework,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.classId = classId
        self.name = name
        self.dueDate = dueDate
        self.description = description
        self.score = score
        self.maxScore = maxScore
        self.weight = weight
        self.type = type
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var scorePercentage: Double? {
        guard let score = score else { return nil }
        return (score / maxScore) * 100
    }
    
    public var isSubmitted: Bool {
        score != nil
    }
    
    public var isDuesoon: Bool {
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return daysUntilDue <= 2 && daysUntilDue >= 0
    }
}

public enum AssignmentType: String, Codable, CaseIterable {
    case homework = "Homework"
    case quiz = "Quiz"
    case exam = "Exam"
    case project = "Project"
    case other = "Other"
}
