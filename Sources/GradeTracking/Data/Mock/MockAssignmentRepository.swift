import Combine
import Core
import Foundation

public class MockAssignmentRepository: AssignmentRepositoryProtocol {
    @Published public var assignments: [Assignment] = []
    private var assignmentsSubject = CurrentValueSubject<[Assignment], Never>([])
    private var cancellables = Set<AnyCancellable>()
    
    private let storageKey = "MockAssignmentRepository_Assignments"
    private let userDefaultsDefaults = UserDefaults.standard
    
    public init() {
        // Load persisted assignments from UserDefaults
        loadFromStorage()
        assignmentsSubject.send(assignments)
    }
    
    // MARK: - Storage
    
    private func loadFromStorage() {
        if let data = userDefaultsDefaults.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                self.assignments = try decoder.decode([Assignment].self, from: data)
            } catch {
                print("Error loading assignments from storage: \(error)")
                self.assignments = []
            }
        }
    }
    
    private func saveToStorage() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(assignments)
            userDefaultsDefaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving assignments to storage: \(error)")
        }
    }
    
    public func createAssignment(_ assignment: Assignment) async throws -> Assignment {
        try await simulateNetworkDelay()
        var newAssignment = assignment
        newAssignment.updatedAt = Date()
        assignments.append(newAssignment)
        saveToStorage()
        assignmentsSubject.send(assignments)
        return newAssignment
    }
    
    public func getAssignments(for classId: String) async throws -> [Assignment] {
        try await simulateNetworkDelay()
        return assignments.filter { $0.classId == classId }
    }
    
    public func getAssignment(by id: String) async throws -> Assignment {
        try await simulateNetworkDelay()
        guard let assignment = assignments.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return assignment
    }
    
    public func updateAssignment(_ assignment: Assignment) async throws -> Assignment {
        try await simulateNetworkDelay()
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            var updated = assignment
            updated.updatedAt = Date()
            assignments[index] = updated
            saveToStorage()
            assignmentsSubject.send(assignments)
            return updated
        }
        throw RepositoryError.notFound
    }
    
    public func deleteAssignment(id: String) async throws {
        try await simulateNetworkDelay()
        assignments.removeAll { $0.id == id }
        saveToStorage()
        assignmentsSubject.send(assignments)
    }
    
    public func getUpcomingAssignments(daysAhead: Int) async throws -> [Assignment] {
        try await simulateNetworkDelay()
        let futureDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
        return assignments.filter { $0.dueDate <= futureDate && $0.dueDate >= Date() }
    }
    
    public func getAssignmentsDue(by date: Date, for classId: String) async throws -> [Assignment] {
        try await simulateNetworkDelay()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return assignments.filter { assignment in
            let assignmentComponents = calendar.dateComponents([.year, .month, .day], from: assignment.dueDate)
            return assignment.classId == classId &&
                   assignmentComponents.year == dateComponents.year &&
                   assignmentComponents.month == dateComponents.month &&
                   assignmentComponents.day == dateComponents.day
        }
    }
    
    public func observeAssignments(for classId: String) -> AnyPublisher<[Assignment], Never> {
        assignmentsSubject
            .map { $0.filter { $0.classId == classId } }
            .eraseToAnyPublisher()
    }
    
    public func observeAssignmentChanges(for classId: String) -> AnyPublisher<DataChange<Assignment>, Never> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        cancellables.removeAll()
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
    }
}

public enum RepositoryError: LocalizedError {
    case notFound
    case invalidData
    
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested item was not found"
        case .invalidData:
            return "The data is invalid"
        }
    }
}
