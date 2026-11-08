import CloudKit
import Combine
import Core
import Foundation
import iCloudIntegration

/// CloudKit-backed implementation of GroupStudySessionRepositoryProtocol
/// Uses Apple's native CloudKit for study session data persistence
public class CloudKitStudySessionRepositoryImpl: GroupStudySessionRepositoryProtocol {
    private let cloudKitManager = CloudKitManager.shared
    private let recordType = CloudKitRecord.RecordType.studySession.rawValue
    
    // Cache for in-memory storage
    private var sessionCache: [String: GroupStudySession] = [:]
    private var sessionsForGroupCache: [String: [GroupStudySession]] = [:]
    private var updateSubject = PassthroughSubject<DataChange<GroupStudySession>, Never>()
    private var sessionsSubject = PassthroughSubject<[GroupStudySession], Never>()
    
    public init() {
        // Subscribe to session changes for real-time updates
        Task {
            try? await cloudKitManager.subscribe(toRecordType: recordType)
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all study sessions for a group
    public func getStudySessions(for groupId: String) async throws -> [GroupStudySession] {
        let predicate = NSPredicate(format: "studyGroupId == %@", groupId)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let sessions = records.compactMap { record in
            GroupStudySession.fromCKRecord(record)
        }
        
        // Cache them
        sessions.forEach { session in
            sessionCache[session.id] = session
        }
        sessionsForGroupCache[groupId] = sessions
        
        return sessions
    }
    
    /// Fetch upcoming study sessions for a user
    public func getUpcomingSessions(for userId: String) async throws -> [GroupStudySession] {
        let now = Date()
        let predicate = NSPredicate(format: "attendeeIds CONTAINS %@ AND scheduledAt > %@", userId, now as NSDate)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        let sessions = records.compactMap { record in
            GroupStudySession.fromCKRecord(record)
        }
        
        return sessions.sorted { $0.scheduledAt < $1.scheduledAt }
    }
    
    /// Fetch a single study session by ID
    public func getStudySession(by id: String) async throws -> GroupStudySession {
        // Check cache first
        if let cached = sessionCache[id] {
            return cached
        }
        
        // Try to fetch from CloudKit
        let predicate = NSPredicate(format: "id == %@", id)
        let records = try await cloudKitManager.query(
            recordType: recordType,
            predicate: predicate
        )
        
        guard let record = records.first,
              let session = GroupStudySession.fromCKRecord(record) else {
            throw CloudKitManager.CloudKitError.recordNotFound
        }
        
        sessionCache[id] = session
        return session
    }
    
    /// Create a new study session
    public func createStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        let record = session.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        sessionCache[session.id] = session
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .added, item: session))
        
        return session
    }
    
    /// Update an existing study session
    public func updateStudySession(_ session: GroupStudySession) async throws -> GroupStudySession {
        let record = session.toCKRecord()
        
        _ = try await cloudKitManager.save(record: record)
        sessionCache[session.id] = session
        
        // Notify subscribers
        updateSubject.send(DataChange(type: .modified, item: session))
        sessionsSubject.send([session])
        
        return session
    }
    
    /// Delete a study session
    public func deleteStudySession(id: String) async throws {
        if sessionCache[id] == nil {
            _ = try await getStudySession(by: id)
        }
        
        let recordID = CKRecord.ID(recordName: id)
        try await cloudKitManager.delete(recordID: recordID)
        
        let deletedSession = sessionCache.removeValue(forKey: id)
        
        // Notify subscribers
        if let session = deletedSession {
            updateSubject.send(DataChange(type: .removed, item: session))
        }
    }
    
    /// Add an attendee to a study session
    public func addAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        var session = try await getStudySession(by: sessionId)
        
        if !session.attendeeIds.contains(userId) {
            session.attendeeIds.append(userId)
            _ = try await updateStudySession(session)
        }
        
        return session
    }
    
    /// Remove an attendee from a study session
    public func removeAttendee(sessionId: String, userId: String) async throws -> GroupStudySession {
        var session = try await getStudySession(by: sessionId)
        
        session.attendeeIds.removeAll { $0 == userId }
        _ = try await updateStudySession(session)
        
        return session
    }
    
    // MARK: - Observers
    
    /// Observe all study sessions for a group
    public func observeStudySessions(for groupId: String) -> AnyPublisher<[GroupStudySession], Never> {
        // Return cached sessions immediately, then listen for updates
        if let cached = sessionsForGroupCache[groupId] {
            sessionsSubject.send(cached)
        }
        
        return sessionsSubject.eraseToAnyPublisher()
    }
    
    /// Observe changes to a specific study session
    public func observeStudySessionChanges(for sessionId: String) -> AnyPublisher<DataChange<GroupStudySession>, Never> {
        return updateSubject.eraseToAnyPublisher()
    }
    
    /// Stop observing changes
    public func stopObserving() {
        sessionCache.removeAll()
        sessionsForGroupCache.removeAll()
    }
}

// MARK: - CloudKit Encoding/Decoding

extension GroupStudySession {
    /// Convert GroupStudySession to CKRecord for CloudKit storage
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: CloudKitRecord.RecordType.studySession.rawValue, recordID: recordID)
        
        let isoFormatter = ISO8601DateFormatter()
        
        record["id"] = id
        record["studyGroupId"] = studyGroupId
        record["title"] = title
        
        if let description = description {
            record["description"] = description
        }
        
        record["scheduledAt"] = isoFormatter.string(from: scheduledAt)
        record["createdAt"] = isoFormatter.string(from: createdAt)
        record["updatedAt"] = isoFormatter.string(from: updatedAt)
        
        // Encode session details
        record["durationMinutes"] = NSNumber(value: durationMinutes)
        record["isVirtual"] = NSNumber(value: isVirtual)
        record["createdBy"] = createdBy
        record["status"] = status.rawValue
        
        // Encode optional fields
        if let location = location {
            record["location"] = location
        }
        
        if let meetingLink = meetingLink {
            record["meetingLink"] = meetingLink
        }
        
        if let maxAttendees = maxAttendees {
            record["maxAttendees"] = NSNumber(value: maxAttendees)
        }
        
        // Encode attendees
        record["attendeeIds"] = attendeeIds as NSArray
        
        return record
    }
    
    /// Create GroupStudySession from CKRecord
    static func fromCKRecord(_ record: CKRecord) -> GroupStudySession? {
        let id = record.recordID.recordName
        let isoFormatter = ISO8601DateFormatter()
        
        guard let studyGroupId = record["studyGroupId"] as? String,
              let title = record["title"] as? String,
              let scheduledAtStr = record["scheduledAt"] as? String,
              let createdAtStr = record["createdAt"] as? String,
              let updatedAtStr = record["updatedAt"] as? String,
              let durationMinutes = record["durationMinutes"] as? NSNumber,
              let isVirtual = record["isVirtual"] as? NSNumber,
              let createdBy = record["createdBy"] as? String,
              let statusString = record["status"] as? String,
              let status = GroupStudySession.SessionStatus(rawValue: statusString),
              let scheduledAt = isoFormatter.date(from: scheduledAtStr),
              let createdAt = isoFormatter.date(from: createdAtStr),
              let updatedAt = isoFormatter.date(from: updatedAtStr) else {
            return nil
        }
        
        let description = record["description"] as? String
        let location = record["location"] as? String
        let meetingLink = record["meetingLink"] as? String
        let maxAttendees = (record["maxAttendees"] as? NSNumber)?.intValue
        let attendeeIds = (record["attendeeIds"] as? [String]) ?? []
        
        return GroupStudySession(
            id: id,
            studyGroupId: studyGroupId,
            title: title,
            description: description,
            scheduledAt: scheduledAt,
            durationMinutes: durationMinutes.intValue,
            location: location,
            isVirtual: isVirtual.boolValue,
            meetingLink: meetingLink,
            createdBy: createdBy,
            attendeeIds: attendeeIds,
            maxAttendees: maxAttendees,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
