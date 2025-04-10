//
//  APIClient.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

final class MUClient {
    static let shared = MUClient(baseURL: URL(string: "http://localhost:3000")!)

    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func send<ResponseType: Decodable>(_ request: MURequest, as responseType: ResponseType.Type) async throws -> ResponseType {
        do {
            return try await performRequest(request, as: responseType)
        } catch let error as NSError where error.code == 401 {
            guard (try? await refreshAccessToken()) != nil else {
                throw error
            }
            return try await performRequest(request, as: responseType)
        } catch let error as NSError where error.code == 403 {
            UserDefaults.standard.removeObject(forKey: TokenKeys.accessToken)
            UserDefaults.standard.removeObject(forKey: TokenKeys.refreshToken)
            throw error
        }
    }
}

// MARK: Private methods

private extension MUClient {

    func performRequest<ResponseType: Decodable>(_ request: MURequest, as responseType: ResponseType.Type) async throws -> ResponseType {
        let url = baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let accessToken = accessToken {
            urlRequest.setValue("Bearer:\(accessToken)", forHTTPHeaderField: "Authorization")
            print("Bearer:\(accessToken)")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(ResponseType.self, from: data)
    }
}

// MARK: Token Management

private extension MUClient {

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: TokenKeys.accessToken) }
        set { UserDefaults.standard.set(newValue, forKey: TokenKeys.accessToken) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: TokenKeys.refreshToken) }
        set { UserDefaults.standard.set(newValue, forKey: TokenKeys.refreshToken) }
    }

    private func refreshAccessToken() async throws -> String {
        guard let refreshToken = refreshToken else {
            throw NSError(domain: "No refresh token", code: 401)
        }

        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("/auth/refresh"))
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refreshToken": refreshToken]
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            UserDefaults.standard.removeObject(forKey: TokenKeys.accessToken)
            UserDefaults.standard.removeObject(forKey: TokenKeys.refreshToken)
            throw NSError(domain: "Token refresh failed", code: 401)
        }

        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)

        self.accessToken = decoded.accessToken
        return decoded.accessToken
    }

}
