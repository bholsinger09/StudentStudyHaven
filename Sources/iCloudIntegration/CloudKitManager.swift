import CloudKit
import Foundation

/// CloudKitManager handles all iCloud/CloudKit operations
/// This is the iOS replacement for Firebase services
public actor CloudKitManager {
    public static let shared = CloudKitManager()

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase
    private let sharedDatabase: CKDatabase
    
    public private(set) var isSignedIn = false
    public private(set) var currentUser: CKUserIdentity?
    
    public enum CloudKitError: LocalizedError {
        case notSignedIn
        case recordNotFound
        case networkError(Error)
        case invalidData(String)
        case unknownError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .notSignedIn:
                return "User is not signed into iCloud"
            case .recordNotFound:
                return "Record not found in CloudKit"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidData(let message):
                return "Invalid data: \(message)"
            case .unknownError(let error):
                return "Unknown error: \(error.localizedDescription)"
            }
        }
    }
    
    private init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
        self.publicDatabase = container.publicCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
    }
    
    /// Initialize CloudKit - Check sign-in status and get user
    public func initialize() async throws {
        do {
            let recordID = try await container.userRecordID()
            let record = try await privateDatabase.record(for: recordID)
            
            self.currentUser = record.creatorUserID
            self.isSignedIn = true
            
            print("✅ CloudKit initialized successfully")
            print("   User: \(recordID.recordName)")
        } catch {
            self.isSignedIn = false
            throw CloudKitError.notSignedIn
        }
    }
    
    /// Request user permission for CloudKit access
    public func requestPermission() async throws {
        try await container.requestApplicationPermission([.userDisclosureData])
    }
    
    /// Fetch a record from private database
    public func fetchRecord(withID recordID: CKRecord.ID) async throws -> CKRecord {
        do {
            return try await privateDatabase.record(for: recordID)
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Save a record to private database
    public func save(record: CKRecord) async throws -> CKRecord {
        do {
            return try await privateDatabase.save(record)
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Save multiple records
    public func save(records: [CKRecord]) async throws -> [CKRecord] {
        do {
            let operation = CKModifyRecordsOperation(recordsToSave: records)
            var savedRecords: [CKRecord] = []
            
            return try await withCheckedThrowingContinuation { continuation in
                operation.modifyRecordsResultBlock = { result in
                    do {
                        let (savedRecs, _) = try result.get()
                        continuation.resume(returning: savedRecs ?? [])
                    } catch {
                        continuation.resume(throwing: CloudKitError.networkError(error))
                    }
                }
                privateDatabase.add(operation)
            }
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Delete a record from private database
    public func delete(recordID: CKRecord.ID) async throws {
        do {
            try await privateDatabase.deleteRecord(withID: recordID)
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Query records from private database
    public func query(recordType: String, predicate: NSPredicate = NSPredicate(value: true)) async throws -> [CKRecord] {
        do {
            let query = CKQuery(recordType: recordType, predicate: predicate)
            let records = try await privateDatabase.records(matching: query)
            
            var results: [CKRecord] = []
            for batch in records {
                results.append(batch.record)
            }
            return results
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Create a subscription for real-time updates
    public func subscribe(toRecordType recordType: String) async throws {
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "subscribe-\(recordType)",
            options: []
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        do {
            try await privateDatabase.save(subscription)
            print("✅ Subscribed to \(recordType) updates")
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Get current user's record ID
    public func getCurrentUserID() async throws -> CKRecord.ID {
        do {
            return try await container.userRecordID()
        } catch {
            throw CloudKitError.notSignedIn
        }
    }
    
    /// Discover other users (for study groups, etc.)
    public func discoverUser(byEmail email: String) async throws -> CKUserIdentity? {
        do {
            let userInfos = try await container.discoverUserInfo(
                withEmailAddress: email
            )
            return userInfos
        } catch {
            return nil
        }
    }
}
