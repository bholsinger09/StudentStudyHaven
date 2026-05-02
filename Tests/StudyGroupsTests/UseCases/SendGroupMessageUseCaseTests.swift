import XCTest
@testable import Core
@testable import StudyGroups

final class SendGroupMessageUseCaseTests: XCTestCase {
    var mockMessageRepository: MockGroupMessageRepository!
    var mockGroupRepository: MockStudyGroupRepository!
    var sut: SendGroupMessageUseCase!
    
    override func setUp() {
        super.setUp()
        mockMessageRepository = MockGroupMessageRepository()
        mockGroupRepository = MockStudyGroupRepository()
        sut = SendGroupMessageUseCase(
            groupMessageRepository: mockMessageRepository,
            studyGroupRepository: mockGroupRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockMessageRepository = nil
        mockGroupRepository = nil
        super.tearDown()
    }
    
    func testSendMessageSuccessfully() async throws {
        // Given
        let userId = "user123"
        let groupId = "group123"
        let group = StudyGroup(
            id: groupId,
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: userId,
            memberIds: [userId, "user456"],
            isPublic: true
        )
        mockGroupRepository.studyGroups = [group]
        
        // When
        let message = try await sut.execute(
            studyGroupId: groupId,
            senderId: userId,
            senderName: "Test User",
            content: "Hey everyone! Ready for tomorrow's study session?"
        )
        
        // Then
        XCTAssertEqual(message.studyGroupId, groupId)
        XCTAssertEqual(message.senderId, userId)
        XCTAssertEqual(message.senderName, "Test User")
        XCTAssertEqual(message.content, "Hey everyone! Ready for tomorrow's study session?")
        XCTAssertEqual(message.messageType, .text)
        XCTAssertFalse(message.isEdited)
        XCTAssertEqual(mockMessageRepository.sendMessageCallCount, 1)
    }
    
    func testSendMessageWithEmptyContent() async {
        // Given
        let userId = "user123"
        let groupId = "group123"
        let group = StudyGroup(
            id: groupId,
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: userId,
            memberIds: [userId],
            isPublic: true
        )
        mockGroupRepository.studyGroups = [group]
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                senderId: userId,
                senderName: "Test User",
                content: ""
            )
            XCTFail("Should throw error for empty content")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("content"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testSendMessageAsNonMember() async {
        // Given
        let userId = "user456" // Not a member
        let groupId = "group123"
        let group = StudyGroup(
            id: groupId,
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: "user123",
            memberIds: ["user123"],
            isPublic: true
        )
        mockGroupRepository.studyGroups = [group]
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                senderId: userId,
                senderName: "Test User",
                content: "Hello!"
            )
            XCTFail("Should throw error for non-member")
        } catch let error as AppError {
            if case .unauthorized = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testSendMessageWithContentTooLong() async {
        // Given
        let userId = "user123"
        let groupId = "group123"
        let group = StudyGroup(
            id: groupId,
            name: "CS101 Study Group",
            classId: "class123",
            collegeId: "college123",
            createdBy: userId,
            memberIds: [userId],
            isPublic: true
        )
        mockGroupRepository.studyGroups = [group]
        
        let longContent = String(repeating: "a", count: 2001) // Over 2000 chars
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                senderId: userId,
                senderName: "Test User",
                content: longContent
            )
            XCTFail("Should throw error for content too long")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("2000"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
