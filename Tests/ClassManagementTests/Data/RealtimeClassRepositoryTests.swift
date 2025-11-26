import XCTest
import Combine
@testable import Core
@testable import ClassManagement

final class RealtimeClassRepositoryTests: XCTestCase {
    var sut: MockClassRepositoryImpl!
    var cancellables: Set<AnyCancellable>!
    let testUserId = "test-user-123"
    
    override func setUp() {
        super.setUp()
        sut = MockClassRepositoryImpl()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - observeClasses Tests
    
    func testObserveClasses_InitialLoad_ReturnsEmptyArray() async throws {
        // Given
        let expectation = expectation(description: "Initial classes received")
        var receivedClasses: [[Class]] = []
        
        // When
        sut.observeClasses(for: testUserId)
            .sink { classes in
                receivedClasses.append(classes)
                if !classes.isEmpty || receivedClasses.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedClasses.first?.count, 0)
    }
    
    func testObserveClasses_WhenClassCreated_ReceivesUpdate() async throws {
        // Given
        let expectation = expectation(description: "Class update received")
        var receivedClasses: [[Class]] = []
        let newClass = createTestClass()
        
        sut.observeClasses(for: testUserId)
            .dropFirst() // Skip initial empty state
            .sink { classes in
                receivedClasses.append(classes)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000) // Let observer initialize
        _ = try await sut.createClass(newClass)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedClasses.last?.count, 1)
        XCTAssertEqual(receivedClasses.last?.first?.id, newClass.id)
    }
    
    func testObserveClasses_WhenClassUpdated_ReceivesUpdate() async throws {
        // Given
        var testClass = createTestClass()
        _ = try await sut.createClass(testClass)
        
        let expectation = expectation(description: "Updated class received")
        var receivedClasses: [[Class]] = []
        
        sut.observeClasses(for: testUserId)
            .dropFirst(2) // Skip initial and create updates
            .sink { classes in
                receivedClasses.append(classes)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        testClass.name = "Updated Name"
        _ = try await sut.updateClass(testClass)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedClasses.last?.first?.name, "Updated Name")
    }
    
    func testObserveClasses_WhenClassDeleted_ReceivesUpdate() async throws {
        // Given
        let testClass = createTestClass()
        let created = try await sut.createClass(testClass)
        
        let expectation = expectation(description: "Deletion update received")
        var receivedClasses: [[Class]] = []
        
        sut.observeClasses(for: testUserId)
            .dropFirst(2) // Skip initial and create updates
            .sink { classes in
                receivedClasses.append(classes)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        try await sut.deleteClass(id: created.id)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedClasses.last?.count, 0)
    }
    
    // MARK: - observeClassChanges Tests
    
    func testObserveClassChanges_WhenClassCreated_ReceivesAddedChange() async throws {
        // Given
        let expectation = expectation(description: "Added change received")
        var receivedChange: DataChange<Class>?
        let newClass = createTestClass()
        
        sut.observeClassChanges(for: testUserId)
            .sink { change in
                receivedChange = change
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        _ = try await sut.createClass(newClass)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedChange?.type, .added)
        XCTAssertEqual(receivedChange?.item.id, newClass.id)
    }
    
    func testObserveClassChanges_WhenClassUpdated_ReceivesModifiedChange() async throws {
        // Given
        var testClass = createTestClass()
        _ = try await sut.createClass(testClass)
        
        let expectation = expectation(description: "Modified change received")
        var receivedChange: DataChange<Class>?
        
        sut.observeClassChanges(for: testUserId)
            .dropFirst() // Skip the create event
            .sink { change in
                receivedChange = change
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        testClass.name = "Modified Name"
        _ = try await sut.updateClass(testClass)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedChange?.type, .modified)
        XCTAssertEqual(receivedChange?.item.name, "Modified Name")
    }
    
    func testObserveClassChanges_WhenClassDeleted_ReceivesRemovedChange() async throws {
        // Given
        let testClass = createTestClass()
        let created = try await sut.createClass(testClass)
        
        let expectation = expectation(description: "Removed change received")
        var receivedChange: DataChange<Class>?
        
        sut.observeClassChanges(for: testUserId)
            .dropFirst() // Skip the create event
            .sink { change in
                receivedChange = change
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        try await sut.deleteClass(id: created.id)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedChange?.type, .removed)
        XCTAssertEqual(receivedChange?.item.id, created.id)
    }
    
    func testObserveClassChanges_FiltersOtherUsers_OnlyReceivesOwnChanges() async throws {
        // Given
        let expectation = expectation(description: "Only own changes received")
        expectation.assertForOverFulfill = false
        var receivedChanges: [DataChange<Class>] = []
        
        let ownClass = createTestClass(userId: testUserId)
        let otherClass = createTestClass(userId: "other-user")
        
        sut.observeClassChanges(for: testUserId)
            .sink { change in
                receivedChanges.append(change)
                if receivedChanges.count >= 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        _ = try await sut.createClass(ownClass)
        _ = try await sut.createClass(otherClass)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedChanges.count, 1)
        XCTAssertEqual(receivedChanges.first?.item.userId, testUserId)
    }
    
    // MARK: - stopObserving Tests
    
    func testStopObserving_StopsReceivingUpdates() async throws {
        // Given
        let expectation = expectation(description: "No updates after stop")
        expectation.isInverted = true
        var updateCount = 0
        
        sut.observeClasses(for: testUserId)
            .dropFirst() // Skip initial
            .sink { _ in
                updateCount += 1
                if updateCount > 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        _ = try await sut.createClass(createTestClass())
        sut.stopObserving()
        _ = try await sut.createClass(createTestClass())
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(updateCount, 1, "Should only receive one update before stopping")
    }
    
    // MARK: - Multiple Subscribers Tests
    
    func testMultipleSubscribers_AllReceiveUpdates() async throws {
        // Given
        let expectation1 = expectation(description: "Subscriber 1 received")
        let expectation2 = expectation(description: "Subscriber 2 received")
        
        sut.observeClasses(for: testUserId)
            .dropFirst()
            .sink { classes in
                if !classes.isEmpty {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.observeClasses(for: testUserId)
            .dropFirst()
            .sink { classes in
                if !classes.isEmpty {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        try await Task.sleep(nanoseconds: 100_000_000)
        _ = try await sut.createClass(createTestClass())
        
        // Then
        await fulfillment(of: [expectation1, expectation2], timeout: 2.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestClass(userId: String? = nil) -> Class {
        Class(
            id: UUID().uuidString,
            userId: userId ?? testUserId,
            name: "Test Class",
            courseCode: "CS101",
            schedule: [],
            professor: "Dr. Test",
            location: "Room 101"
        )
    }
}
