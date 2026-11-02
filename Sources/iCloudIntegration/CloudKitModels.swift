import CloudKit
import Foundation

/// Extension for encoding Swift objects to CKRecord
public extension CKRecord {
    convenience init(recordType: String, from dictionary: [String: Any]) {
        self.init(recordType: recordType)
        for (key, value) in dictionary {
            self[key] = value as? CKRecordValue
        }
    }
    
    /// Convert CKRecord to dictionary
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        
        for key in self.allKeys() {
            if let value = self[key] {
                dictionary[key] = value
            }
        }
        
        return dictionary
    }
}

/// Helper for common CloudKit record operations
public struct CloudKitRecord {
    public enum RecordType: String {
        case user = "User"
        case `class` = "Class"
        case assignment = "Assignment"
        case grade = "Grade"
        case gpa = "GPA"
        case studyGroup = "StudyGroup"
        case groupAssignment = "GroupAssignment"
    }
    
    public static func create(_ type: RecordType, fields: [String: Any]) -> CKRecord {
        let record = CKRecord(recordType: type.rawValue)
        
        for (key, value) in fields {
            if let value = value as? String {
                record[key] = value
            } else if let value = value as? Int {
                record[key] = NSNumber(value: value)
            } else if let value = value as? Double {
                record[key] = NSNumber(value: value)
            } else if let value = value as? Bool {
                record[key] = NSNumber(value: value)
            } else if let value = value as? Date {
                record[key] = value
            } else if let value = value as? [String] {
                record[key] = value as CKRecordValue
            } else if let value = value as? CKReference {
                record[key] = value
            }
        }
        
        return record
    }
}

/// Codable support for CloudKit records
public protocol CloudKitCodable: Codable {
    var recordID: CKRecord.ID? { get set }
    func toCKRecord() -> CKRecord
    static func fromCKRecord(_ record: CKRecord) -> Self?
}
