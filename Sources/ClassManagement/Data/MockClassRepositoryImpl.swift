import Combine
import Core
import Foundation

/// Mock implementation of ClassRepository for development and testing
/// Uses UserDefaults for local persistence so data survives app restarts
public final class MockClassRepositoryImpl: ClassRepositoryProtocol {
    private var classes: [String: Class] = [:]
    private let classesSubject = CurrentValueSubject<[Class], Never>([])
    private let changesSubject = PassthroughSubject<DataChange<Class>, Never>()
    private var isObserving = false
    
    private let storageKey = "MockClassRepository_Classes"
    private let userDefaultsDefaults = UserDefaults.standard

    public init() {
        // Load persisted classes from UserDefaults
        loadFromStorage()
    }
    
    // MARK: - Storage
    
    private func loadFromStorage() {
        if let data = userDefaultsDefaults.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                let classes = try decoder.decode([Class].self, from: data)
                for classItem in classes {
                    self.classes[classItem.id] = classItem
                }
            } catch {
                print("Error loading classes from storage: \(error)")
            }
        }
    }
    
    private func saveToStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(Array(classes.values))
            userDefaultsDefaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving classes to storage: \(error)")
        }
    }

    public func getClasses(for userId: String) async throws -> [Class] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        // Return classes for this userId
        return classes.values.filter { $0.userId == userId }
    }

    public func getClass(by id: String) async throws -> Class {
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
        saveToStorage()

        if isObserving {
            changesSubject.send(DataChange(type: .added, item: classItem))
            updateClassesSubject()
        }

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
        saveToStorage()

        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: updatedClass))
            updateClassesSubject()
        }

        return updatedClass
    }

    public func deleteClass(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let deletedClass = classes[id] else {
            throw AppError.notFound("Class not found")
        }

        classes.removeValue(forKey: id)
        saveToStorage()

        if isObserving {
            changesSubject.send(DataChange(type: .removed, item: deletedClass))
            updateClassesSubject()
        }
    }

    // MARK: - Real-time listeners

    public func observeClasses(for userId: String) -> AnyPublisher<[Class], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialClasses = try await getClasses(for: userId)
                classesSubject.send(initialClasses)
            } catch {
                classesSubject.send([])
            }
        }
        return classesSubject.eraseToAnyPublisher()
    }

    public func observeClassChanges(for userId: String) -> AnyPublisher<DataChange<Class>, Never> {
        isObserving = true
        return
            changesSubject
            .filter { $0.item.userId == userId }
            .eraseToAnyPublisher()
    }

    public func stopObserving() {
        isObserving = false
    }

    // MARK: - Private helpers

    private func updateClassesSubject() {
        let allClasses = Array(classes.values)
        classesSubject.send(allClasses)
    }
}
