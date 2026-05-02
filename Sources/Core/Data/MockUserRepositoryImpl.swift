import Foundation

/// Mock implementation of UserRepositoryProtocol for testing and development
public class MockUserRepositoryImpl: UserRepositoryProtocol {
    private var users: [String: User] = [:]
    
    public init() {
        // Pre-populate with some test users
        let testUsers = [
            User(
                id: "user1",
                email: "john.doe@college.edu",
                name: "John Doe",
                collegeId: "college1"
            ),
            User(
                id: "user2",
                email: "jane.smith@college.edu",
                name: "Jane Smith",
                collegeId: "college1"
            ),
            User(
                id: "user3",
                email: "bob.johnson@college.edu",
                name: "Bob Johnson",
                collegeId: "college1"
            )
        ]
        
        for user in testUsers {
            users[user.id] = user
        }
    }
    
    public func getUser(by id: String) async throws -> User {
        guard let user = users[id] else {
            throw AppError.notFound("User not found")
        }
        return user
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func updateUser(_ user: User) async throws -> User {
        users[user.id] = user
        return user
    }
    
    public func deleteUser(id: String) async throws {
        users.removeValue(forKey: id)
    }
    
    public func searchUsers(firstName: String, email: String, collegeId: String) async throws -> [User] {
        let nameLowercase = firstName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let emailLowercase = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return users.values.filter { user in
            guard user.collegeId == collegeId else { return false }
            
            let userFirstName = user.name.components(separatedBy: " ").first?.lowercased() ?? ""
            let userEmail = user.email.lowercased()
            
            let nameMatches = userFirstName.contains(nameLowercase) || nameLowercase.contains(userFirstName)
            let emailMatches = userEmail == emailLowercase
            
            return nameMatches && emailMatches
        }
    }
    
    public func searchUsersByEmail(email: String, collegeId: String) async throws -> User? {
        let emailLowercase = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return users.values.first { user in
            user.collegeId == collegeId && user.email.lowercased() == emailLowercase
        }
    }
}
