import FirebaseIntegration
import FirebaseFirestore
import Combine
import Core
import Foundation

/// Firebase-backed implementation of AssignmentRepositoryProtocol
/// CRITICAL: Grade tracking depends on this repository being accurate
public class FirestoreAssignmentRepositoryImpl: AssignmentRepositoryProtocol {
    private let database = DatabaseService.shared
    private let collectionName = "assignments"
    private var listenerRegistrations: [ListenerRegistration] = []
    
    public init() {}
    
    // MARK: - CRUD Operations
    
    /// Fetch all assignments for a class
    public func getAssignments(for classId: String) async throws -> [Assignment] {
        return try await database.query(
            collectionName,
            where: [("classId", classId)],
            as: Assignment.self
        )
    }
    
    /// Fetch a single assignment by ID
    public func getAssignment(by id: String) async throws -> Assignment {
        let path = "\(collectionName)/\(id)"
        return try await database.get(from: path, as: Assignment.self)
    }
    
    /// Create a new assignment
    public func createAssignment(_ assignment: Assignment) async throws -> Assignment {
        let path = "\(collectionName)/\(assignment.id)"
        try await database.set(assignment, at: path)
        return assignment
    }
    
    /// Update an assignment
    /// NOTE: This is called when grades are entered
    public func updateAssignment(_ assignment: Assignment) async throws -> Assignment {
        let path = "\(collectionName)/\(assignment.id)"
        
        // Encode model to dictionary
        guard let encoded = try? JSONEncoder().encode(assignment),
              var dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode assignment"])
        }
        
        // Update server timestamp
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        try await database.update(path, with: dict)
        return assignment
    }
    
    /// Delete an assignment
    public func deleteAssignment(id: String) async throws {
        let path = "\(collectionName)/\(id)"
        try await database.delete(at: path)
    }
    
    // MARK: - Query Operations
    
    /// Fetch assignments due within N days
    public func getUpcomingAssignments(daysAhead: Int) async throws -> [Assignment] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let futureDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: today) else {
            return []
        }
        
        // Fetch all assignments and filter client-side
        // NOTE: Firestore date queries are complex, so we filter in-memory
        let allAssignments = try await database.query(
            collectionName,
            as: Assignment.self
        )
        
        return allAssignments.filter { assignment in
            assignment.dueDate >= today && assignment.dueDate <= futureDate
        }
    }
    
    /// Fetch assignments due by a specific date in a class
    public func getAssignmentsDue(by date: Date, for classId: String) async throws -> [Assignment] {
        let assignments = try await getAssignments(for: classId)
        
        // Filter to those due on or before the given date
        return assignments.filter { $0.dueDate <= date }
    }
    
    // MARK: - Real-time Listeners
    
    /// Observe all assignments for a class
    public func observeAssignments(for classId: String) -> AnyPublisher<[Assignment], Never> {
        let subject = CurrentValueSubject<[Assignment], Never>([])
        
        let listener = database.listenToCollection(
            collectionName,
            as: Assignment.self,
            onUpdate: { assignments in
                // Filter assignments for this class
                let filtered = assignments.filter { $0.classId == classId }
                subject.send(filtered)
            },
            onError: { error in
                print("❌ Error observing assignments: \(error)")
                subject.send([])
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Observe changes to assignments in a class
    public func observeAssignmentChanges(for classId: String) -> AnyPublisher<DataChange<Assignment>, Never> {
        let subject = PassthroughSubject<DataChange<Assignment>, Never>()
        
        let listener = database.listenToCollection(
            collectionName,
            as: Assignment.self,
            onUpdate: { assignments in
                // Emit changes for this class's assignments
                let classAssignments = assignments.filter { $0.classId == classId }
                classAssignments.forEach { assignment in
                    let change = DataChange(type: .modified, item: assignment)
                    subject.send(change)
                }
            },
            onError: { error in
                print("❌ Error observing assignment changes: \(error)")
            }
        )
        
        listenerRegistrations.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    /// Stop all real-time listeners
    public func stopObserving() {
        listenerRegistrations.forEach { $0.remove() }
        listenerRegistrations.removeAll()
    }
    
    deinit {
        stopObserving()
    }
}
