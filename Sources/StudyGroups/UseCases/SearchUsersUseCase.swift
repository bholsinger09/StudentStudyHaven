import Core
import Foundation

/// Use case for searching users by first name and email
public final class SearchUsersUseCase {
    private let userRepository: UserRepositoryProtocol
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    public func execute(
        firstName: String,
        email: String,
        collegeId: String
    ) async throws -> [User] {
        // Validate inputs
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirstName.isEmpty else {
            throw AppError.invalidData("First name cannot be empty")
        }
        
        guard !trimmedEmail.isEmpty else {
            throw AppError.invalidData("Email cannot be empty")
        }
        
        // Validate email format
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            throw AppError.invalidData("Invalid email format")
        }
        
        // Use provided collegeId or default to "Boise State University" for testing
        let finalCollegeId = collegeId.isEmpty ? "Boise State University" : collegeId
        
        // Search for users
        return try await userRepository.searchUsers(
            firstName: trimmedFirstName,
            email: trimmedEmail,
            collegeId: finalCollegeId
        )
    }
}
