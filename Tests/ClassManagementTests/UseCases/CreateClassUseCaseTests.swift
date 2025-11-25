import XCTest

@testable import ClassManagement
@testable import Core

final class CreateClassUseCaseTests: XCTestCase {
    var mockRepository: MockClassRepository!
    var sut: CreateClassUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockClassRepository()
        sut = CreateClassUseCase(classRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testCreateClassWithValidData() async throws {
        // Given
        let userId = UUID()
        let classItem = Class(
            userId: userId,
            name: "Introduction to CS",
            courseCode: "CS101"
        )
        mockRepository.createResult = .success(classItem)

        // When
        let result = try await sut.execute(classItem: classItem)

        // Then
        XCTAssertEqual(result.name, "Introduction to CS")
        XCTAssertEqual(result.courseCode, "CS101")
        XCTAssertEqual(mockRepository.createCallCount, 1)
    }

    func testCreateClassWithEmptyName() async {
        // Given
        let userId = UUID()
        let classItem = Class(
            userId: userId,
            name: "",
            courseCode: "CS101"
        )

        // When/Then
        do {
            _ = try await sut.execute(classItem: classItem)
            XCTFail("Should throw error for empty name")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("name"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func testCreateClassWithOverlappingTimeSlots() async {
        // Given
        let userId = UUID()
        let baseTime = Date()
        let timeSlot1 = TimeSlot(
            dayOfWeek: .monday,
            startTime: baseTime,
            endTime: baseTime.addingTimeInterval(3600)  // 1 hour
        )
        let timeSlot2 = TimeSlot(
            dayOfWeek: .monday,
            startTime: baseTime.addingTimeInterval(1800),  // 30 minutes later
            endTime: baseTime.addingTimeInterval(5400)  // Overlaps with first
        )

        let classItem = Class(
            userId: userId,
            name: "Test Class",
            courseCode: "TEST101",
            schedule: [timeSlot1, timeSlot2]
        )

        // When/Then
        do {
            _ = try await sut.execute(classItem: classItem)
            XCTFail("Should throw error for overlapping time slots")
        } catch let error as AppError {
            if case .invalidData(let message) = error {
                XCTAssertTrue(message.contains("overlap"))
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Mock Repository
class MockClassRepository: ClassRepositoryProtocol {
    var createCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var getClassesCallCount = 0

    var createResult: Result<Class, Error> = .failure(AppError.unknown("Not configured"))
    var updateResult: Result<Class, Error> = .failure(AppError.unknown("Not configured"))
    var getClassesResult: Result<[Class], Error> = .failure(AppError.unknown("Not configured"))

    func getClasses(for userId: UUID) async throws -> [Class] {
        getClassesCallCount += 1
        return try getClassesResult.get()
    }

    func getClass(by id: UUID) async throws -> Class {
        throw AppError.notFound("Class not found")
    }

    func createClass(_ classItem: Class) async throws -> Class {
        createCallCount += 1
        return try createResult.get()
    }

    func updateClass(_ classItem: Class) async throws -> Class {
        updateCallCount += 1
        return try updateResult.get()
    }

    func deleteClass(id: UUID) async throws {
        deleteCallCount += 1
    }
}
