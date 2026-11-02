import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of AssignmentRepositoryProtocol
/// Uses Apple's native CloudKit for grade tracking data persistence
public class CloudKitAssignmentRepositoryImpl: AssignmentRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.assignment.rawValue
    
    // Cache for in-memory storage
    private var assignmentCache: [String: Assignment] = [:]
    private var updateSubjects: [String: PassthroughSubject<Assignment, Never>] = [:]
    
    public init() {
        // Subscribe to assignment changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all assignments for a class
    public func getAssignments(for classId: String) async throws -> [Assignment] {
        let predicate = NSPredicate(format: "classId == %@", classId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let assignments = records.compactMap { record in
            Assignment.fromCKRecord(record)
        }
        
        // Cache them
        assignments.forEach { assignment in
            assignmentCache[assignment.id] = assignment
        }
        
        return assignments
    }
    
    /// Fetch a single assignment by ID
    public func getAssignment(by id: String) async throws -> Assignment {
        // Check cache first
        if let cached = assignmentCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let assignment = Assignment.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        assignmentCache[id] = assignment
        return assignment
    }
    
    /// Create a new assignment
    public func createAssignment(_ assignment: Assignment) async throws -> Assignment {
        let record = assignment.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        assignmentCache[assignment.id] = assignment
        
        // Notify subscribers
        if let subject = updateSubjects[assignment.classId] {
            subject.send(assignment)
        }
        
        return assignment
    }
    
    /// Update an assignment
    public func updateAssignment(_ assignment: Assignment) async throws -> Assignment {
        var updatedAssignment = assignment
        updatedAssignment.updatedAt = Date()
        
        let record = updatedAssignment.toCKRecord()
        _ = try await cloudKitManager.save(record: record)
        
        assignmentCache[assignment.id] = updatedAssignment
        
        // Notify subscribers
        if let subject = updateSubjects[assignment.classId] {
            subject.send(updatedAssignment)
        }
        
        return updatedAssignment
    }
    
    /// Delete an assignment
    public func deleteAssignment(id: String) async throws {
        if assignmentCache[id] == nil {
            // Try to fetch first to ensure it exists
            _ = try await getAssignment(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        assignmentCache.removeValue(forKey: id)
    }
    
    // MARK: - Query Operations
    
    /// Fetch assignments due within N days
    public func getUpcomingAssignments(daysAhead: Int) async throws -> [Assignment] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let futureDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: today) else {
            return []
        }
        
        // CloudKit doesn't support complex date range queries, so we fetch all and filter
        let records = try await cloudKitManager.query(recordType: recordType)
        
        let assignments = records.compactMap { record in
            Assignment.fromCKRecord(record)
        }
        
        return assignments.filter { assignment in
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
        
        // Load initial data
        Task {
            do {
                let assignments = try await getAssignments(for: classId)
                subject.send(assignments)
            } catch {
                print("❌ Error fetching assignments: \(error)")
                subject.send([])
            }
        }
        
        // Set up update subject for this class
        let updateSubject = PassthroughSubject<Assignment, Never>()
        updateSubjects[classId] = updateSubject
        
        // Merge initial data with updates
        return Publishers.Merge(
            subject,
            updateSubject
                .scan([]) { assignments, newAssignment in
                    var result = assignments
                    if let index = result.firstIndex(where: { $0.id == newAssignment.id }) {
                        result[index] = newAssignment
                    } else {
                        result.append(newAssignment)
                    }
                    return result
                }
        )
        .eraseToAnyPublisher()
    }
    
    /// Observe changes to assignments in a class
    public func observeAssignmentChanges(for classId: String) -> AnyPublisher<DataChange<Assignment>, Never> {
        let subject = PassthroughSubject<DataChange<Assignment>, Never>()
        
        // Create an update subject for this class
        let updateSubject = PassthroughSubject<Assignment, Never>()
        updateSubjects[classId] = updateSubject
        
        // Convert assignment updates to DataChange events
        let changePublisher = updateSubject
            .map { assignment in
                DataChange(type: .modified, item: assignment)
            }
        
        return changePublisher.eraseToAnyPublisher()
    }
    
    /// Stop all real-time listeners
    public func stopObserving() {
        updateSubjects.removeAll()
    }
    
    deinit {
        stopObserving()
    }
}

// MARK: - CloudKit Encoding Extensions

extension Assignment {
    /// Convert Assignment to CloudKit record
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.assignment.rawValue, recordID: recordID)
        
        record["id"] = id
        record["classId"] = classId
        record["name"] = name
        record["dueDate"] = dueDate
        record["maxScore"] = NSNumber(value: maxScore)
        record["weight"] = NSNumber(value: weight)
        record["type"] = type.rawValue
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        
        // Handle optional fields
        if let description = description {
            record["description"] = description
        }
        
        if let score = score {
            record["score"] = NSNumber(value: score)
        }
        
        return record
    }
    
    /// Create Assignment from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> Assignment? {
        guard let id = record["id"] as? String,
              let classId = record["classId"] as? String,
              let name = record["name"] as? String,
              let dueDate = record["dueDate"] as? Date,
              let maxScore = record["maxScore"] as? Double,
              let weight = record["weight"] as? Double,
              let typeString = record["type"] as? String,
              let type = AssignmentType(rawValue: typeString),
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }
        
        let description = record["description"] as? String
        let score = record["score"] as? Double
        
        return Assignment(
            id: id,
            classId: classId,
            name: name,
            dueDate: dueDate,
            description: description,
            score: score,
            maxScore: maxScore,
            weight: weight,
            type: type,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
