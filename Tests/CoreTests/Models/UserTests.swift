import XCTest
@testable import Core

final class UserTests: XCTestCase {
    func testUserInitialization() {
        let user = User(
            email: "test@example.com",
            name: "Test User"
        )
        
        XCTAssertNotNil(user.id)
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertNil(user.collegeId)
    }
    
    func testUserEquality() {
        let id = UUID()
        let user1 = User(id: id, email: "test@example.com", name: "Test")
        let user2 = User(id: id, email: "test@example.com", name: "Test")
        
        XCTAssertEqual(user1, user2)
    }
    
    func testUserCodable() throws {
        let user = User(email: "test@example.com", name: "Test User")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.id, decodedUser.id)
        XCTAssertEqual(user.email, decodedUser.email)
        XCTAssertEqual(user.name, decodedUser.name)
    }
}
