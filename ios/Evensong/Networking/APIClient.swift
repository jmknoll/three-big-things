import Foundation

enum APIError: Error, LocalizedError {
    case unauthorized
    case notFound
    case validation(String)
    case server(String)
    case network
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized:       return "Please sign in again."
        case .notFound:           return "Resource not found."
        case .validation(let m):  return m
        case .server(let m):      return m
        case .network:            return "Network error. Check your connection."
        case .decoding(let e):    return "Response error: \(e.localizedDescription)"
        }
    }
}

private struct ErrorResponse: Decodable {
    let error: String
}

actor APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? "http://localhost:8080"
        session = URLSession.shared
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint, body: (some Encodable)? = nil as String?) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.network
        }

        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth {
            if let token = try await TokenStore.shared.get() {
                req.setValue(token, forHTTPHeaderField: "x-access-token")
            }
        }

        if let body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            req.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw APIError.network }

        switch http.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        case 401:
            try await TokenStore.shared.clear()
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 422:
            let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Validation error."
            throw APIError.validation(msg)
        default:
            let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Server error."
            throw APIError.server(msg)
        }
    }

    /// Convenience for endpoints returning no body (e.g. { "ok": true })
    func requestVoid(_ endpoint: APIEndpoint, body: (some Encodable)? = nil as String?) async throws {
        let _: EmptyResponse = try await request(endpoint, body: body)
    }
}

private struct EmptyResponse: Decodable {}
