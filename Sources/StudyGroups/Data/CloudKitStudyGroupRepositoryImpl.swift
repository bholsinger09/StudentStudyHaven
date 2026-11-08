import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of StudyGroupRepositoryProtocol
/// Uses Apple's native CloudKit for study group data persistence
public class CloudKitStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.studyGroup.rawValue
    
    // Cache for in-memory storage
    private var groupCache: [String: StudyGroup] = [:]
    private var groupsForUserCache: [String: [StudyGroup]] = [:]
    private var updateSubject = PassthroughSubject<DataChange<StudyGroup>, Never>()
    private var groupsSubject = PassthroughSubject<[StudyGroup], Never>()
    
    public init() {
        // Subscribe to study group changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all study groups for a user
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        let predicate = NSPredicate(format: "memberIds CONTAINS %@", userId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let groups = records.compactMap { record in
            StudyGroup.fromCKRecord(record)
        }
        
        // Cache them
        groups.forEach { group in
            groupCache[group.id] = group
        }
        groupsForUserCache[userId] = groups
        
        return groups
    }
    
    /// Fetch a single study group by ID
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        // Check cache first
        if let cached = groupCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit by record ID (the ID is used as the record name)
        let recordID = CKRecord.ID(recordName: id)
        let record = try await cloudKitManager.fetchRecord(withID: recordID)
        
        guard let group = StudyGroup.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        groupCache[id] = group
        return group
    }
    
    /// Fetch public study groups for a college/class
    public func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        var predicateFormat = "collegeId == %@ AND isPublic == 1"
        var predicateArgs: [Any] = [collegeId]
        
        if let classId = classId {
            predicateFormat += " AND classId == %@"
            predicateArgs.append(classId)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let groups = records.compactMap { record in
            StudyGroup.fromCKRecord(record)
        }
        
        return groups
    }
    
    /// Create a new study group
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        let record = studyGroup.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        groupCache[studyGroup.id] = studyGroup
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .added, item: studyGroup))
        
        return studyGroup
    }
    
    /// Update an existing study group
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        // Fetch the current record to preserve etag and change tag
        let recordID = CKRecord.ID(recordName: studyGroup.id)
        let currentRecord = try await cloudKitManager.fetchRecord(withID: recordID)
        
        // Update fields in-place on the existing record
        let isoFormatter = ISO8601DateFormatter()
        
        currentRecord["name"] = studyGroup.name
        currentRecord["classId"] = studyGroup.classId
        currentRecord["collegeId"] = studyGroup.collegeId
        currentRecord["createdBy"] = studyGroup.createdBy
        currentRecord["isPublic"] = NSNumber(value: studyGroup.isPublic)
        currentRecord["memberIds"] = studyGroup.memberIds
        currentRecord["createdAt"] = isoFormatter.string(from: studyGroup.createdAt)
        currentRecord["updatedAt"] = isoFormatter.string(from: studyGroup.updatedAt)
        
        if let description = studyGroup.description {
            currentRecord["description"] = description
        } else {
            currentRecord["description"] = nil
        }
        
        if let maxMembers = studyGroup.maxMembers {
            currentRecord["maxMembers"] = NSNumber(value: maxMembers)
        } else {
            currentRecord["maxMembers"] = nil
        }
        
        // Save the updated record (preserves etag)
        _ = try await cloudKitManager.save(record: currentRecord)
        groupCache[studyGroup.id] = studyGroup
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .modified, item: studyGroup))
        groupsSubject.send([studyGroup])
        
        return studyGroup
    }
    
    /// Delete a study group
    public func deleteStudyGroup(id: String) async throws {
        if groupCache[id] == nil {
            _ = try await getStudyGroup(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        let deletedGroup = groupCache.removeValue(forKey: id)
        
        // Notify subscribers
        if let group = deletedGroup {
            updateSubject.send(DataChange(type: .removed, item: group))
        }
    }
    
    /// Add a member to a study group
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        var retryCount = 0
        let maxRetries = 3
        var backoffDelay: UInt64 = 100_000_000 // Start at 100ms
        
        while retryCount <= maxRetries {
            do {
                var group = try await getStudyGroup(by: groupId)
                
                if !group.memberIds.contains(userId) {
                    group.memberIds.append(userId)
                    let updated = try await updateStudyGroup(group)
                    print("✅ CloudKitStudyGroupRepositoryImpl: Successfully added member after \(retryCount) retries")
                    return updated
                }
                
                return group
            } catch let error as CloudKitManager.CloudKitError {
                // Check for server record changed error
                if case .networkError(let nsError) = error {
                    let errorString = nsError.localizedDescription
                    print("🔍 CloudKitStudyGroupRepositoryImpl: Error details: \(errorString)")
                    
                    if let ckError = nsError as? CKError {
                        print("🔍 CloudKitStudyGroupRepositoryImpl: CKError code: \(ckError.code.rawValue)")
                        
                        if ckError.code == .serverRecordChanged {
                            retryCount += 1
                            if retryCount <= maxRetries {
                                print("⚠️ CloudKitStudyGroupRepositoryImpl: Server record changed, retrying (attempt \(retryCount)/\(maxRetries))...")
                                // Clear cache to force fresh fetch
                                groupCache.removeValue(forKey: groupId)
                                // Exponential backoff: 100ms, 200ms, 400ms
                                try? await Task.sleep(nanoseconds: backoffDelay)
                                backoffDelay *= 2
                                continue
                            } else {
                                print("❌ CloudKitStudyGroupRepositoryImpl: Max retries (\(maxRetries)) exceeded for server record conflict")
                                throw AppError.networkError("Unable to join group after multiple attempts. Please try again later.")
                            }
                        }
                    }
                }
                throw error
            }
        }
        
        throw AppError.networkError("Failed to add member after retries")
    }
    
    /// Remove a member from a study group
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        var group = try await getStudyGroup(by: groupId)
        
        group.memberIds.removeAll { $0 == userId }
        _ = try await updateStudyGroup(group)
        
        return group
    }
    
    // MARK: - Observers
    
    /// Observe all study groups for a user
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        // Return cached groups immediately, then listen for updates
        if let cached = groupsForUserCache[userId] {
            groupsSubject.send(cached)
        }
        
        return groupsSubject.eraseToAnyPublisher()
    }
    
    /// Observe changes to a specific study group
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        groupCache.removeAll()
        groupsForUserCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension StudyGroup {
    /// Convert StudyGroup to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.studyGroup.rawValue, recordID: recordID)
        
        let isoFormatter = ISO8601DateFormatter()
        
        record["id"] = id
        record["name"] = name
        record["classId"] = classId
        record["collegeId"] = collegeId
        record["createdBy"] = createdBy
        record["isPublic"] = NSNumber(value: isPublic)
        record["memberIds"] = memberIds
        record["createdAt"] = isoFormatter.string(from: createdAt)
        record["updatedAt"] = isoFormatter.string(from: updatedAt)
        
        if let description = description {
            record["description"] = description
        }
        
        if let maxMembers = maxMembers {
            record["maxMembers"] = NSNumber(value: maxMembers)
        }
        
        return record
    }
    
    /// Create StudyGroup from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> StudyGroup? {
        guard let id = record.recordID.recordName as? String,
              let name = record["name"] as? String,
              let classId = record["classId"] as? String,
              let collegeId = record["collegeId"] as? String,
              let createdBy = record["createdBy"] as? String,
              let isPublic = record["isPublic"] as? NSNumber,
              let memberIds = record["memberIds"] as? [String],
              let createdAtStr = record["createdAt"] as? String,
              let updatedAtStr = record["updatedAt"] as? String else {
            return nil
        }
        
        let isoFormatter = ISO8601DateFormatter()
        
        guard let createdAt = isoFormatter.date(from: createdAtStr),
              let updatedAt = isoFormatter.date(from: updatedAtStr) else {
            return nil
        }
        
        let description = record["description"] as? String
        let maxMembers = (record["maxMembers"] as? NSNumber)?.intValue
        
        return StudyGroup(
            id: id,
            name: name,
            classId: classId,
            collegeId: collegeId,
            description: description,
            createdBy: createdBy,
            memberIds: memberIds,
            maxMembers: maxMembers,
            isPublic: isPublic.boolValue,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
