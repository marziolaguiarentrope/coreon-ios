import Foundation

// MARK: - Base44 API Client
// Swift equivalent of the Base44 JavaScript SDK

final class Base44Client {
    static let shared = Base44Client()

    private let baseURL: String
    private let appID: String
    private var authToken: String? {
        get { KeychainStorage.shared.get(key: "base44_token") }
        set {
            if let token = newValue {
                KeychainStorage.shared.set(key: "base44_token", value: token)
            } else {
                KeychainStorage.shared.delete(key: "base44_token")
            }
        }
    }

    private let session: URLSession

    private init() {
        self.appID = Bundle.main.object(forInfoDictionaryKey: "BASE44_APP_ID") as? String
            ?? "68ef9008cb8386859dc75818"
        self.baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE44_BASE_URL") as? String
            ?? "https://app.base44.com/api/apps/68ef9008cb8386859dc75818"
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Auth Namespace
    var auth: AuthNamespace { AuthNamespace(client: self) }

    // MARK: - Entities Namespace
    func entities<T: Codable & Identifiable>(_ name: String) -> EntityNamespace<T> {
        EntityNamespace<T>(client: self, entityName: name)
    }

    // MARK: - Integrations Namespace
    var integrations: IntegrationsNamespace { IntegrationsNamespace(client: self) }

    // MARK: - Internal request
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw Base44Error.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw Base44Error.noResponse
        }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw Base44Error.unauthorized
        }
        if !(200..<300).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw Base44Error.serverError(http.statusCode, msg)
        }
        return try JSONDecoder.base44.decode(T.self, from: data)
    }

    func setToken(_ token: String?) {
        authToken = token
    }

    func getToken() -> String? { authToken }
}

// MARK: - Auth Namespace
struct AuthNamespace {
    let client: Base44Client

    func me() async throws -> User {
        return try await client.request(path: "/auth/me")
    }

    func loginWithEmail(email: String, password: String) async throws -> AuthResponse {
        return try await client.request(
            path: "/auth/login",
            method: "POST",
            body: ["email": email, "password": password]
        )
    }

    func signUp(email: String, password: String, fullName: String) async throws -> AuthResponse {
        return try await client.request(
            path: "/auth/register",
            method: "POST",
            body: ["email": email, "password": password, "full_name": fullName]
        )
    }

    func verifyOtp(email: String, code: String) async throws -> AuthResponse {
        return try await client.request(
            path: "/auth/verify-otp",
            method: "POST",
            body: ["email": email, "code": code]
        )
    }

    func resendOtp(email: String) async throws -> MessageResponse {
        return try await client.request(
            path: "/auth/resend-otp",
            method: "POST",
            body: ["email": email]
        )
    }

    func logout() {
        client.setToken(nil)
    }
}

// MARK: - Entity Namespace
struct EntityNamespace<T: Codable & Identifiable> {
    let client: Base44Client
    let entityName: String

    private var basePath: String { "/entities/\(entityName)" }

    func list(sortBy: String? = nil) async throws -> [T] {
        var path = basePath
        if let sort = sortBy { path += "?sort=\(sort)" }
        return try await client.request(path: path)
    }

    func filter(_ query: [String: Any], sortBy: String? = nil) async throws -> [T] {
        var components = URLComponents(string: "https://placeholder\(basePath)")!
        var items = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        if let sort = sortBy { items.append(URLQueryItem(name: "sort", value: sort)) }
        components.queryItems = items
        let path = basePath + "?" + (components.percentEncodedQuery ?? "")
        return try await client.request(path: path)
    }

    func get(id: String) async throws -> T {
        return try await client.request(path: "\(basePath)/\(id)")
    }

    func create(_ data: [String: Any]) async throws -> T {
        return try await client.request(path: basePath, method: "POST", body: data)
    }

    func update(id: String, _ data: [String: Any]) async throws -> T {
        return try await client.request(path: "\(basePath)/\(id)", method: "PUT", body: data)
    }

    func delete(id: String) async throws -> MessageResponse {
        return try await client.request(path: "\(basePath)/\(id)", method: "DELETE")
    }

    func bulkCreate(_ items: [[String: Any]]) async throws -> [T] {
        return try await client.request(
            path: "\(basePath)/bulk",
            method: "POST",
            body: ["items": items]
        )
    }
}

// MARK: - Integrations Namespace
struct IntegrationsNamespace {
    let client: Base44Client

    func invokeLLM(prompt: String) async throws -> String {
        let resp: LLMResponse = try await client.request(
            path: "/integrations/core/llm",
            method: "POST",
            body: ["prompt": prompt]
        )
        return resp.result
    }
}

// MARK: - Errors
enum Base44Error: LocalizedError {
    case invalidURL
    case noResponse
    case unauthorized
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noResponse: return "No response from server"
        case .unauthorized: return "Unauthorized — please login again"
        case .serverError(let code, let msg): return "Server error \(code): \(msg)"
        }
    }
}

// MARK: - Response Types
struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct MessageResponse: Codable {
    let message: String
}

struct LLMResponse: Codable {
    let result: String
}

// MARK: - JSONDecoder helper
extension JSONDecoder {
    static var base44: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = formatter.date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(str)")
        }
        return d
    }
}
