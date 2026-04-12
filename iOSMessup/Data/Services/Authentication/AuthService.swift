//
//  AuthService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class AuthService: AuthServiceProtocol {
    private(set) var isAuthenticated: Bool

    private let client: MUClientProtocol
    private let tokenStorage: TokenStorageProtocol

    init(client: MUClientProtocol, tokenStorage: TokenStorageProtocol) {
        self.client = client
        self.tokenStorage = tokenStorage
        self.isAuthenticated = tokenStorage.getRefreshToken() != nil
    }

    @MainActor
    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        do {
            let response = try await client.send(request, as: LoginResponse.self)
            tokenStorage.save(tokens: AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
            isAuthenticated = true
        } catch {
            throw AuthError.invalidCredentials
        }
    }

    @MainActor
    func logout() {
        tokenStorage.clearTokens()
        isAuthenticated = false
    }

    @MainActor
    func register(email: String, password: String, name: String) async throws {
        let request = RegisterRequest(email: email, password: password, name: name)
        do {
            let response = try await client.send(request, as: RegisterResponse.self)
            tokenStorage.save(tokens: AuthTokens(accessToken: response.accessToken, refreshToken: response.refreshToken))
            isAuthenticated = true
        } catch {
            throw AuthError.userAlreadyExists
        }
    }

    @MainActor
    func resetPassword(for email: String) async throws {
        // TODO: Implement real API call
        try await Task.sleep(for: .seconds(1))
    }

    @MainActor
    func refreshSession() async throws {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            throw AuthError.tokenRefreshFailed
        }
        // TODO: Implement real token refresh API call
        try await Task.sleep(for: .seconds(1))
    }
}
