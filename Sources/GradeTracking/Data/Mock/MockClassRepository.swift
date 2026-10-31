import Combine
import Core
import Foundation

public class MockClassRepository: ClassRepositoryProtocol {
    public init() {}
    
    public func getClasses(for userId: String) async throws -> [Class] {
        return [
            Class(id: UUID().uuidString, userId: userId, name: "Introduction to Computer Science", courseCode: "CS 101", schedule: [], professor: "Dr. Smith"),
            Class(id: UUID().uuidString, userId: userId, name: "Calculus II", courseCode: "MATH 201", schedule: [], professor: "Dr. Johnson")
        ]
    }
    
    public func getClass(by id: String) async throws -> Class {
        throw RepositoryError.notFound
    }
    
    public func createClass(_ classItem: Class) async throws -> Class {
        return classItem
    }
    
    public func updateClass(_ classItem: Class) async throws -> Class {
        return classItem
    }
    
    public func deleteClass(id: String) async throws {}
    
    public func observeClasses(for userId: String) -> AnyPublisher<[Class], Never> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func observeClassChanges(for userId: String) -> AnyPublisher<DataChange<Class>, Never> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func stopObserving() {}
}
