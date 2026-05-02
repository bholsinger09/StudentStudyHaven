import XCTest
@testable import Core
@testable import StudyGroups

final class JoinStudyGroupUseCaseTests: XCTestCase {
    var mockRepository: MockStudyGroupRepository!
    var sut: JoinStudyGroupUseCase!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockStudyGroupRepository()
        sut = JoinStudyGroupUseCase(studyGroupRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testJoinPublicStudyGroupSuccessfully() async throws {
        // Given
        let userId = "user456"
        let group = StudyGroup(
            id: "group123",
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: "user123",
            memberIds: ["user123"],
            maxMembers: 10,
            isPublic: true
        )
        mockRepository.studyGroups = [group]
        
        // When
        let updatedGroup = try await sut.execute(groupId: group.id, userId: userId)
        
        // Then
        XCTAssertTrue(updatedGroup.memberIds.contains(userId))
        XCTAssertEqual(updatedGroup.memberIds.count, 2)
        XCTAssertEqual(mockRepository.addMemberCallCount, 1)
    }
    
    func testJoinStudyGroupWhenAlreadyMember() async {
        // Given
        let userId = "user123"
        let group = StudyGroup(
            id: "group123",
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: userId,
            memberIds: [userId],
            isPublic: true
        )
        mockRepository.studyGroups = [group]
        
        // When/Then
        do {
            _ = try await sut.execute(groupId: group.id, userId: userId)
            XCTFail("Should throw error when already a member")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("already"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testJoinStudyGroupWhenFull() async {
        // Given
        let userId = "user456"
        let group = StudyGroup(
            id: "group123",
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: "user123",
            memberIds: ["user123", "user124"],
            maxMembers: 2, // Already full
            isPublic: true
        )
        mockRepository.studyGroups = [group]
        
        // When/Then
        do {
            _ = try await sut.execute(groupId: group.id, userId: userId)
            XCTFail("Should throw error when group is full")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("full"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testJoinNonExistentStudyGroup() async {
        // Given
        mockRepository.studyGroups = []
        
        // When/Then
        do {
            _ = try await sut.execute(groupId: "nonexistent", userId: "user123")
            XCTFail("Should throw error for non-existent group")
        } catch let error as AppError {
            if case .notFound = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
