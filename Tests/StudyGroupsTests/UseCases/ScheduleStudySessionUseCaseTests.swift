import XCTest
@testable import Core
@testable import StudyGroups

final class ScheduleStudySessionUseCaseTests: XCTestCase {
    var mockSessionRepository: MockStudySessionRepository!
    var mockGroupRepository: MockStudyGroupRepository!
    var sut: ScheduleStudySessionUseCase!
    
    override func setUp() {
        super.setUp()
        mockSessionRepository = MockStudySessionRepository()
        mockGroupRepository = MockStudyGroupRepository()
        sut = ScheduleStudySessionUseCase(
            studySessionRepository: mockSessionRepository,
            studyGroupRepository: mockGroupRepository
        )
    }
    
    override func tearDown() {
        sut = nil
        mockSessionRepository = nil
        mockGroupRepository = nil
        super.tearDown()
    }
    
    func testScheduleStudySessionSuccessfully() async throws {
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
        
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // When
        let session = try await sut.execute(
            studyGroupId: groupId,
            title: "Midterm Review",
            description: "Chapters 1-5",
            scheduledAt: futureDate,
            durationMinutes: 90,
            location: "Library 3rd Floor",
            isVirtual: false,
            meetingLink: nil,
            createdBy: userId,
            maxAttendees: 8
        )
        
        // Then
        XCTAssertEqual(session.studyGroupId, groupId)
        XCTAssertEqual(session.title, "Midterm Review")
        XCTAssertEqual(session.durationMinutes, 90)
        XCTAssertEqual(session.createdBy, userId)
        XCTAssertTrue(session.attendeeIds.contains(userId)) // Creator auto-attends
        XCTAssertEqual(session.status, .scheduled)
        XCTAssertEqual(mockSessionRepository.createStudySessionCallCount, 1)
    }
    
    func testScheduleStudySessionWithPastDate() async {
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
        
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                title: "Past Session",
                description: nil,
                scheduledAt: pastDate,
                durationMinutes: 60,
                location: nil,
                isVirtual: false,
                meetingLink: nil,
                createdBy: userId,
                maxAttendees: nil
            )
            XCTFail("Should throw error for past date")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("future"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testScheduleStudySessionForNonMember() async {
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
        
        let futureDate = Date().addingTimeInterval(86400)
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                title: "Session",
                description: nil,
                scheduledAt: futureDate,
                durationMinutes: 60,
                location: nil,
                isVirtual: false,
                meetingLink: nil,
                createdBy: userId,
                maxAttendees: nil
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
    
    func testScheduleStudySessionWithEmptyTitle() async {
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
        
        let futureDate = Date().addingTimeInterval(86400)
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                title: "",
                description: nil,
                scheduledAt: futureDate,
                durationMinutes: 60,
                location: nil,
                isVirtual: false,
                meetingLink: nil,
                createdBy: userId,
                maxAttendees: nil
            )
            XCTFail("Should throw error for empty title")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("title"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testScheduleVirtualSessionWithoutMeetingLink() async {
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
        
        let futureDate = Date().addingTimeInterval(86400)
        
        // When/Then
        do {
            _ = try await sut.execute(
                studyGroupId: groupId,
                title: "Virtual Session",
                description: nil,
                scheduledAt: futureDate,
                durationMinutes: 60,
                location: nil,
                isVirtual: true,
                meetingLink: nil, // Missing link for virtual session
                createdBy: userId,
                maxAttendees: nil
            )
            XCTFail("Should throw error for virtual session without meeting link")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("meeting link"))
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
}
