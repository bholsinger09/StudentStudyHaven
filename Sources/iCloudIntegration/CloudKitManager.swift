import CloudKit
import Foundation

/// CloudKitManager handles all iCloud/CloudKit operations
/// This is the iOS replacement for Firebase services
public actor CloudKitManager {
    public static let shared = CloudKitManager()

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    
    public private(set) var isSignedIn = false
    
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
    }
    
    /// Initialize CloudKit - Check sign-in status
    public func initialize() async throws {
        do {
            let recordID = try await container.userRecordID()
            self.isSignedIn = true
            
            print("✅ CloudKit initialized successfully")
            print("   User: \(recordID.recordName)")
        } catch {
            self.isSignedIn = false
            throw CloudKitError.notSignedIn
        }
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
    
    /// Delete a record from private database
    public func delete(recordID: CKRecord.ID) async throws {
        do {
            try await privateDatabase.deleteRecord(withID: recordID)
        } catch {
            throw CloudKitError.networkError(error)
        }
    }
    
    /// Query records from private database using CKQueryOperation
    public func query(recordType: String, predicate: NSPredicate = NSPredicate(value: true)) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = CKQuery(recordType: recordType, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            var results: [CKRecord] = []
            
            operation.recordMatchedBlock = { _, result in
                if case .success(let record) = result {
                    results.append(record)
                }
            }
            
            operation.queryResultBlock = { result in
                do {
                    _ = try result.get()
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: CloudKitError.networkError(error))
                }
            }
            
            privateDatabase.add(operation)
        }
    }
    
    /// Subscribe to record type changes
    public func subscribe(toRecordType recordType: String) async throws {
        // Note: Subscriptions in CloudKit require push notifications to be set up
        // For now, we skip subscriptions to avoid crashes during initialization
        // Real-time updates can be implemented via manual polling if needed
        print("ℹ️  Subscriptions disabled (requires push notification setup)")
    }
    
    /// Get current user's record ID
    public func getCurrentUserID() async throws -> CKRecord.ID {
        do {
            return try await container.userRecordID()
        } catch {
            throw CloudKitError.notSignedIn
        }
    }
}
