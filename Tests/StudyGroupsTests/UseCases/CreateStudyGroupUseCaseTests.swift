import XCTest
@testable import Core
@testable import StudyGroups

final class CreateStudyGroupUseCaseTests: XCTestCase {
    var mockRepository: MockStudyGroupRepository!
    var sut: CreateStudyGroupUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockStudyGroupRepository()
        sut = CreateStudyGroupUseCase(studyGroupRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testCreateStudyGroupWithValidData() async throws {
        // Given
        let userId = "user123"
        let name = "CS101 Study Group"
        let classId = "class123"
        let collegeId = "college123"
        
        // When
        let group = try await sut.execute(
            name: name,
            classId: classId,
            collegeId: collegeId,
            description: "Let's ace this class!",
            createdBy: userId,
            maxMembers: 10,
            isPublic: true
        )
        
        // Then
        XCTAssertEqual(group.name, name)
        XCTAssertEqual(group.classId, classId)
        XCTAssertEqual(group.collegeId, collegeId)
        XCTAssertEqual(group.createdBy, userId)
        XCTAssertTrue(group.memberIds.contains(userId)) // Creator auto-joins
        XCTAssertEqual(group.maxMembers, 10)
        XCTAssertTrue(group.isPublic)
        XCTAssertEqual(mockRepository.createStudyGroupCallCount, 1)
    }
    
    func testCreateStudyGroupWithEmptyName() async {
        // Given
        let userId = "user123"
        let classId = "class123"
        let collegeId = "college123"
        
        // When/Then
        do {
            _ = try await sut.execute(
                name: "",
                classId: classId,
                collegeId: collegeId,
                description: nil,
                createdBy: userId,
                maxMembers: nil,
                isPublic: true
            )
            XCTFail("Should throw error for empty name")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("name"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testCreateStudyGroupWithInvalidMaxMembers() async {
        // Given
        let userId = "user123"
        let classId = "class123"
        let collegeId = "college123"
        
        // When/Then
        do {
            _ = try await sut.execute(
                name: "Study Group",
                classId: classId,
                collegeId: collegeId,
                description: nil,
                createdBy: userId,
                maxMembers: 0, // Invalid: must be at least 2
                isPublic: true
            )
            XCTFail("Should throw error for invalid maxMembers")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("member"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testCreateStudyGroupRepositoryError() async {
        // Given
        mockRepository.error = AppError.serverError("Database unavailable")
        
        // When/Then
        do {
            _ = try await sut.execute(
                name: "Study Group",
                classId: "class123",
                collegeId: "college123",
                description: nil,
                createdBy: "user123",
                maxMembers: nil,
                isPublic: true
            )
            XCTFail("Should throw repository error")
        } catch let error as AppError {
            if case .serverError = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
