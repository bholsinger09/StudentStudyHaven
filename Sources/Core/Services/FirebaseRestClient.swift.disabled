import Foundation

/// REST API client for Firebase services (Auth & Firestore)
/// Eliminates need for Firebase SDK - uses pure HTTP requests
public class FirebaseRestClient {
    private let projectId: String
    private let apiKey: String
    
    // Firebase REST API endpoints
    private let authBaseURL = "https://identitytoolkit.googleapis.com/v1/accounts"
    private var firestoreBaseURL: String {
        "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents"
    }
    
    public init(projectId: String, apiKey: String) {
        self.projectId = projectId
        self.apiKey = apiKey
    }
    
    // MARK: - Authentication
    
    /// Sign in with email and password
    public func signIn(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(authBaseURL):signInWithPassword?key=\(apiKey)")!
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        
        return try await post(url: url, body: body)
    }
    
    /// Register new user with email and password
    public func signUp(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(authBaseURL):signUp?key=\(apiKey)")!
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        
        return try await post(url: url, body: body)
    }
    
    /// Refresh ID token
    public func refreshToken(_ refreshToken: String) async throws -> RefreshTokenResponse {
        let url = URL(string: "https://securetoken.googleapis.com/v1/token?key=\(apiKey)")!
        let body: [String: Any] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        
        return try await post(url: url, body: body)
    }
    
    /// Get user info
    public func getUserInfo(idToken: String) async throws -> UserInfoResponse {
        let url = URL(string: "\(authBaseURL):lookup?key=\(apiKey)")!
        let body: [String: Any] = ["idToken": idToken]
        
        return try await post(url: url, body: body)
    }
    
    // MARK: - Firestore
    
    /// Get document from Firestore
    public func getDocument(path: String, idToken: String) async throws -> FirestoreDocument {
        let url = URL(string: "\(firestoreBaseURL)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(FirestoreDocument.self, from: data)
    }
    
    /// Create/Update document in Firestore
    public func setDocument(path: String, data: [String: Any], idToken: String) async throws -> FirestoreDocument {
        let url = URL(string: "\(firestoreBaseURL)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let firestoreData = convertToFirestoreFormat(data)
        request.httpBody = try JSONSerialization.data(withJSONObject: ["fields": firestoreData])
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(FirestoreDocument.self, from: responseData)
    }
    
    /// Delete document from Firestore
    public func deleteDocument(path: String, idToken: String) async throws {
        let url = URL(string: "\(firestoreBaseURL)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
    }
    
    /// Query documents in a collection
    public func queryDocuments(collectionPath: String, idToken: String, filter: FirestoreFilter? = nil) async throws -> [FirestoreDocument] {
        let url = URL(string: "\(firestoreBaseURL):runQuery")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var query: [String: Any] = [
            "structuredQuery": [
                "from": [["collectionId": collectionPath]]
            ]
        ]
        
        if let filter = filter {
            var structuredQuery = query["structuredQuery"] as! [String: Any]
            structuredQuery["where"] = filter.toFirestoreQuery()
            query["structuredQuery"] = structuredQuery
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        let results = try JSONDecoder().decode([QueryResult].self, from: data)
        return results.compactMap { $0.document }
    }
    
    // MARK: - Helper Methods
    
    private func post<T: Decodable>(url: URL, body: [String: Any]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FirebaseRestError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw FirebaseRestError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    /// Convert Swift dictionary to Firestore REST API format
    private func convertToFirestoreFormat(_ data: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, value) in data {
            result[key] = convertValueToFirestoreFormat(value)
        }
        
        return result
    }
    
    private func convertValueToFirestoreFormat(_ value: Any) -> [String: Any] {
        switch value {
        case let string as String:
            return ["stringValue": string]
        case let int as Int:
            return ["integerValue": "\(int)"]
        case let double as Double:
            return ["doubleValue": double]
        case let bool as Bool:
            return ["booleanValue": bool]
        case let date as Date:
            return ["timestampValue": ISO8601DateFormatter().string(from: date)]
        case let array as [Any]:
            let values = array.map { convertValueToFirestoreFormat($0) }
            return ["arrayValue": ["values": values]]
        case let dict as [String: Any]:
            return ["mapValue": ["fields": convertToFirestoreFormat(dict)]]
        default:
            return ["nullValue": NSNull()]
        }
    }
}

// MARK: - Response Models

public struct AuthResponse: Codable {
    public let idToken: String
    public let refreshToken: String
    public let expiresIn: String
    public let localId: String
    public let email: String?
}

public struct RefreshTokenResponse: Codable {
    public let id_token: String
    public let refresh_token: String
    public let expires_in: String
    public let user_id: String
}

public struct UserInfoResponse: Codable {
    public let users: [UserInfo]
    
    public struct UserInfo: Codable {
        public let localId: String
        public let email: String
        public let emailVerified: Bool
    }
}

public struct FirestoreDocument: Codable {
    public let name: String
    public let fields: [String: FirestoreValue]?
    public let createTime: String?
    public let updateTime: String?
}

public struct QueryResult: Codable {
    public let document: FirestoreDocument?
}

public enum FirestoreValue: Codable {
    case stringValue(String)
    case integerValue(String)
    case doubleValue(Double)
    case booleanValue(Bool)
    case timestampValue(String)
    case arrayValue([FirestoreValue])
    case mapValue([String: FirestoreValue])
    case nullValue
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? container.decode(String.self, forKey: .stringValue) {
            self = .stringValue(value)
        } else if let value = try? container.decode(String.self, forKey: .integerValue) {
            self = .integerValue(value)
        } else if let value = try? container.decode(Double.self, forKey: .doubleValue) {
            self = .doubleValue(value)
        } else if let value = try? container.decode(Bool.self, forKey: .booleanValue) {
            self = .booleanValue(value)
        } else if let value = try? container.decode(String.self, forKey: .timestampValue) {
            self = .timestampValue(value)
        } else if let arrayContainer = try? container.nestedContainer(keyedBy: ArrayCodingKeys.self, forKey: .arrayValue),
                  let values = try? arrayContainer.decode([FirestoreValue].self, forKey: .values) {
            self = .arrayValue(values)
        } else if let mapContainer = try? container.nestedContainer(keyedBy: MapCodingKeys.self, forKey: .mapValue),
                  let fields = try? mapContainer.decode([String: FirestoreValue].self, forKey: .fields) {
            self = .mapValue(fields)
        } else {
            self = .nullValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .stringValue(let value):
            try container.encode(value, forKey: .stringValue)
        case .integerValue(let value):
            try container.encode(value, forKey: .integerValue)
        case .doubleValue(let value):
            try container.encode(value, forKey: .doubleValue)
        case .booleanValue(let value):
            try container.encode(value, forKey: .booleanValue)
        case .timestampValue(let value):
            try container.encode(value, forKey: .timestampValue)
        case .arrayValue(let values):
            var arrayContainer = container.nestedContainer(keyedBy: ArrayCodingKeys.self, forKey: .arrayValue)
            try arrayContainer.encode(values, forKey: .values)
        case .mapValue(let fields):
            var mapContainer = container.nestedContainer(keyedBy: MapCodingKeys.self, forKey: .mapValue)
            try mapContainer.encode(fields, forKey: .fields)
        case .nullValue:
            try container.encodeNil(forKey: .nullValue)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case stringValue, integerValue, doubleValue, booleanValue
        case timestampValue, arrayValue, mapValue, nullValue
    }
    
    enum ArrayCodingKeys: String, CodingKey {
        case values
    }
    
    enum MapCodingKeys: String, CodingKey {
        case fields
    }
}

// MARK: - Firestore Filter

public struct FirestoreFilter {
    public let field: String
    public let op: FilterOperator
    public let value: Any
    
    public enum FilterOperator: String {
        case equal = "EQUAL"
        case lessThan = "LESS_THAN"
        case greaterThan = "GREATER_THAN"
    }
    
    public init(field: String, op: FilterOperator, value: Any) {
        self.field = field
        self.op = op
        self.value = value
    }
    
    func toFirestoreQuery() -> [String: Any] {
        [
            "fieldFilter": [
                "field": ["fieldPath": field],
                "op": op.rawValue,
                "value": convertValue(value)
            ]
        ]
    }
    
    private func convertValue(_ value: Any) -> [String: Any] {
        switch value {
        case let string as String:
            return ["stringValue": string]
        case let int as Int:
            return ["integerValue": "\(int)"]
        case let double as Double:
            return ["doubleValue": double]
        case let bool as Bool:
            return ["booleanValue": bool]
        default:
            return ["nullValue": NSNull()]
        }
    }
}

// MARK: - Errors

public enum FirebaseRestError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
