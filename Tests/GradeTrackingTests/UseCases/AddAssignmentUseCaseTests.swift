import XCTest
@testable import GradeTracking
import Core

class AddAssignmentUseCaseTests: XCTestCase {
    var sut: AddAssignmentUseCase!
    var mockRepository: MockAssignmentRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAssignmentRepository()
        sut = AddAssignmentUseCase(assignmentRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testAddAssignment_Success() async throws {
        let classId = UUID().uuidString
        let name = "Homework 1"
        let dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        let weight = 10.0
        
        let assignment = try await sut.execute(
            classId: classId,
            name: name,
            dueDate: dueDate,
            weight: weight
        )
        
        XCTAssertEqual(assignment.name, name)
        XCTAssertEqual(assignment.classId, classId)
        XCTAssertEqual(assignment.weight, weight)
    }
    
    func testAddAssignment_EmptyName_Throws() async {
        let classId = UUID().uuidString
        let dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        
        do {
            _ = try await sut.execute(
                classId: classId,
                name: "",
                dueDate: dueDate,
                weight: 10
            )
            XCTFail("Expected ValidationError.emptyName")
        } catch ValidationError.emptyName {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAddAssignment_InvalidWeight_Throws() async {
        let classId = UUID().uuidString
        let dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
        
        do {
            _ = try await sut.execute(
                classId: classId,
                name: "Assignment",
                dueDate: dueDate,
                weight: 150 // Invalid weight
            )
            XCTFail("Expected ValidationError.invalidWeight")
        } catch ValidationError.invalidWeight {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
