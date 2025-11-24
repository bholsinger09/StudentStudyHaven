import Foundation
import Core

/// Mock implementation of ClassRepository for development and testing
public final class MockClassRepositoryImpl: ClassRepositoryProtocol {
    private var classes: [UUID: Class] = [:]
    
    public init() {}
    
    public func getClasses(for userId: UUID) async throws -> [Class] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return classes.values.filter { $0.userId == userId }
    }
    
    public func getClass(by id: UUID) async throws -> Class {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let classItem = classes[id] else {
            throw AppError.notFound("Class not found")
        }
        
        return classItem
    }
    
    public func createClass(_ classItem: Class) async throws -> Class {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        classes[classItem.id] = classItem
        return classItem
    }
    
    public func updateClass(_ classItem: Class) async throws -> Class {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard classes[classItem.id] != nil else {
            throw AppError.notFound("Class not found")
        }
        
        var updatedClass = classItem
        updatedClass.updatedAt = Date()
        classes[classItem.id] = updatedClass
        return updatedClass
    }
    
    public func deleteClass(id: UUID) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard classes[id] != nil else {
            throw AppError.notFound("Class not found")
        }
        
        classes.removeValue(forKey: id)
    }
}
