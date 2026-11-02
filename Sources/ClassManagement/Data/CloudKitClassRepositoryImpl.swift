import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of ClassRepositoryProtocol
/// Uses Apple's native CloudKit for class data persistence
public class CloudKitClassRepositoryImpl: ClassRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.class.rawValue
    
    // Cache for in-memory storage
    private var classCache: [String: Class] = [:]
    private var classesForUserCache: [String: [Class]] = [:]
    private var updateSubject = PassthroughSubject<DataChange<Class>, Never>()
    private var classesSubject = PassthroughSubject<[Class], Never>()
    
    public init() {
        // Subscribe to class changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all classes for a user
    public func getClasses(for userId: String) async throws -> [Class] {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let classes = records.compactMap { record in
            Class.fromCKRecord(record)
        }
        
        // Cache them
        classes.forEach { classItem in
            classCache[classItem.id] = classItem
        }
        classesForUserCache[userId] = classes
        
        return classes
    }
    
    /// Fetch a single class by ID
    public func getClass(by id: String) async throws -> Class {
        // Check cache first
        if let cached = classCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let classItem = Class.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        classCache[id] = classItem
        return classItem
    }
    
    /// Create a new class
    public func createClass(_ classItem: Class) async throws -> Class {
        let record = classItem.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        classCache[classItem.id] = classItem
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .added, item: classItem))
        
        return classItem
    }
    
    /// Update an existing class
    public func updateClass(_ classItem: Class) async throws -> Class {
        let record = classItem.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        classCache[classItem.id] = classItem
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .modified, item: classItem))
        classesSubject.send([classItem])
        
        return classItem
    }
    
    /// Delete a class
    public func deleteClass(id: String) async throws {
        if classCache[id] == nil {
            _ = try await getClass(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        let deletedClass = classCache.removeValue(forKey: id)
        
        // Notify subscribers
        if let classItem = deletedClass {
            updateSubject.send(DataChange(type: .removed, item: classItem))
        }
    }
    
    // MARK: - Observers
    
    /// Observe all classes for a user
    public func observeClasses(for userId: String) -> AnyPublisher<[Class], Never> {
        // Return cached classes immediately, then listen for updates
        if let cached = classesForUserCache[userId] {
            classesSubject.send(cached)
        }
        
        return classesSubject.eraseToAnyPublisher()
    }
    
    /// Observe changes to classes for a user
    public func observeClassChanges(for userId: String) -> AnyPublisher<DataChange<Class>, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        classCache.removeAll()
        classesForUserCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension Class {
    /// Convert Class to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.class.rawValue, recordID: recordID)
        
        record["id"] = id
        record["userId"] = userId
        record["name"] = name
        record["courseCode"] = courseCode
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        
        // Encode optional fields
        if let professor = professor {
            record["professor"] = professor
        }
        
        if let location = location {
            record["location"] = location
        }
        
        // Encode schedule
        if let scheduleData = try? JSONEncoder().encode(schedule),
           let scheduleJSON = String(data: scheduleData, encoding: .utf8) {
            record["schedule"] = scheduleJSON
        }
        
        return record
    }
    
    /// Create Class from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Class? {
        let id = record.recordID.recordName
        guard let userId = record["userId"] as? String,
              let name = record["name"] as? String,
              let courseCode = record["courseCode"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }
        
        let professor = record["professor"] as? String
        let location = record["location"] as? String
        
        var schedule: [Class.TimeSlot] = []
        if let scheduleJSON = record["schedule"] as? String,
           let scheduleData = scheduleJSON.data(using: .utf8),
           let decodedSchedule = try? JSONDecoder().decode([Class.TimeSlot].self, from: scheduleData) {
            schedule = decodedSchedule
        }
        
        return Class(
            id: id,
            userId: userId,
            name: name,
            courseCode: courseCode,
            schedule: schedule,
            professor: professor,
            location: location,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
