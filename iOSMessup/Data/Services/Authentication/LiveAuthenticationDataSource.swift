//
//  LiveAuthenticationDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//

import Foundation

class LiveAuthenticationDataSource: AuthenticationDataSourceProtocol {
    private let apiClient = MUClient(baseURL: URL(string: "http://localhost:3000")!)

    func login(email: String, password: String) async throws -> AuthTokens {
        let request = LoginRequest(email: email, password: password)
        do {
            let response = try await apiClient.send(request, as: LoginResponse.self)
            return AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        } catch {
            throw AuthError.invalidCredentials
        }
    }

    func register(email: String, password: String, name: String) async throws -> AuthTokens {
        let request = RegisterRequest(email: email, password: password, name: name)
        do {
            let response = try await apiClient.send(request, as: RegisterResponse.self)
            return AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        } catch {
            throw AuthError.userAlreadyExists
        }
    }

    func resetPassword(for email: String) async throws {
        print("Password reset requested for \(email)")
        try await Task.sleep(for: .seconds(1))
    }

    func refreshToken(using token: String) async throws -> AuthTokens {
        print("Attempting to refresh token")
        try await Task.sleep(for: .seconds(1))
        return AuthTokens(accessToken: "new_refreshed_access_token", refreshToken: "new_refreshed_refresh_token")
    }
}
