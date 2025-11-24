import XCTest
@testable import Core

final class ClassTests: XCTestCase {
    func testClassInitialization() {
        let userId = UUID()
        let classItem = Class(
            userId: userId,
            name: "Introduction to Computer Science",
            courseCode: "CS101"
        )
        
        XCTAssertNotNil(classItem.id)
        XCTAssertEqual(classItem.userId, userId)
        XCTAssertEqual(classItem.name, "Introduction to Computer Science")
        XCTAssertEqual(classItem.courseCode, "CS101")
        XCTAssertTrue(classItem.schedule.isEmpty)
    }
    
    func testTimeSlotInitialization() {
        let startTime = Date()
        let endTime = Date().addingTimeInterval(3600) // 1 hour later
        
        let timeSlot = TimeSlot(
            dayOfWeek: .monday,
            startTime: startTime,
            endTime: endTime
        )
        
        XCTAssertNotNil(timeSlot.id)
        XCTAssertEqual(timeSlot.dayOfWeek, .monday)
        XCTAssertEqual(timeSlot.startTime, startTime)
        XCTAssertEqual(timeSlot.endTime, endTime)
    }
    
    func testClassWithSchedule() {
        let userId = UUID()
        let timeSlot = TimeSlot(
            dayOfWeek: .monday,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )
        
        let classItem = Class(
            userId: userId,
            name: "Math 101",
            courseCode: "MATH101",
            schedule: [timeSlot]
        )
        
        XCTAssertEqual(classItem.schedule.count, 1)
        XCTAssertEqual(classItem.schedule.first?.dayOfWeek, .monday)
    }
}
