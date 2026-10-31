import XCTest
@testable import GradeTracking
import Core

class CalculateClassGradeUseCaseTests: XCTestCase {
    var sut: CalculateClassGradeUseCase!
    var mockRepository: MockAssignmentRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAssignmentRepository()
        sut = CalculateClassGradeUseCase(assignmentRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testCalculateClassGrade_EmptyAssignments() async throws {
        let classId = UUID().uuidString
        
        let courseGrade = try await sut.execute(classId: classId)
        
        XCTAssertEqual(courseGrade.currentGrade, 0.0)
        XCTAssertEqual(courseGrade.letterGrade, "F")
    }
    
    func testCalculateClassGrade_AllA() async throws {
        let classId = UUID().uuidString
        
        // Add assignments with perfect scores
        let assignment1 = Assignment(
            classId: classId,
            name: "Assignment 1",
            dueDate: Date(),
            score: 100,
            maxScore: 100,
            weight: 50,
            type: .homework
        )
        
        let assignment2 = Assignment(
            classId: classId,
            name: "Assignment 2",
            dueDate: Date(),
            score: 100,
            maxScore: 100,
            weight: 50,
            type: .homework
        )
        
        _ = try await mockRepository.createAssignment(assignment1)
        _ = try await mockRepository.createAssignment(assignment2)
        
        let courseGrade = try await sut.execute(classId: classId)
        
        XCTAssertEqual(courseGrade.currentGrade, 100.0)
        XCTAssertEqual(courseGrade.letterGrade, "A")
    }
    
    func testCalculateClassGrade_WeightedAverage() async throws {
        let classId = UUID().uuidString
        
        // Assignment 1: 80% weight (50 points)
        let assignment1 = Assignment(
            classId: classId,
            name: "Homework",
            dueDate: Date(),
            score: 80,
            maxScore: 100,
            weight: 50,
            type: .homework
        )
        
        // Assignment 2: 20% weight (50 points)
        let assignment2 = Assignment(
            classId: classId,
            name: "Quiz",
            dueDate: Date(),
            score: 100,
            maxScore: 100,
            weight: 50,
            type: .quiz
        )
        
        _ = try await mockRepository.createAssignment(assignment1)
        _ = try await mockRepository.createAssignment(assignment2)
        
        let courseGrade = try await sut.execute(classId: classId)
        
        // (80 * 50 + 100 * 50) / (50 + 50) = 9000 / 100 = 90
        XCTAssertEqual(courseGrade.currentGrade, 90.0)
        XCTAssertEqual(courseGrade.letterGrade, "A")
    }
}
