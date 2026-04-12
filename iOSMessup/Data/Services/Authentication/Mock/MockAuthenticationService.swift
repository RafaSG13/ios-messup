//
//  MockAuthenticationService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import SwiftUI

@Observable
final class MockAuthService: AuthServiceProtocol {
    // MARK: - UI State
    private(set) var isAuthenticated: Bool
    var mockUser: User?

    // MARK: - Testing & Internal State
    private(set) var currentTokens: AuthTokens?
    var delay: TimeInterval
    var shouldFail: Bool
    var customError: Error?

    init(isAuthenticated: Bool = false,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false,
         customError: Error? = nil,
         mockUser: User? = nil,
         currentTokens: AuthTokens? = nil) {
        self.isAuthenticated = isAuthenticated
        self.delay = delay
        self.shouldFail = shouldFail
        self.customError = customError
        self.mockUser = mockUser ?? User(id: "mock-id", name: "Mock User", email: "mock@example.com", userImage: nil)
        self.currentTokens = currentTokens
    }

    // MARK: - Private Helpers
    private func simulateNetwork() async throws {
        try await Task.sleep(for: .seconds(delay))

        if shouldFail {
            throw customError ?? AuthError.networkError(NSError(domain: "NetworkError", code: -1))
        }
    }

    // MARK: - Protocol Conformance

    @MainActor
    func login(email: String, password: String) async throws {
        try await simulateNetwork()
        currentTokens = AuthTokens(accessToken: "mock_access_token_login", refreshToken: "mock_refresh_token_login")
        isAuthenticated = true
    }

    @MainActor
    func logout() {
        currentTokens = nil
        isAuthenticated = false
    }

    @MainActor
    func register(email: String, password: String, name: String) async throws {
        try await simulateNetwork()
        currentTokens = AuthTokens(accessToken: "mock_access_token_register", refreshToken: "mock_refresh_token_register")
        isAuthenticated = true
    }

    @MainActor
    func resetPassword(for email: String) async throws {
        try await simulateNetwork()
    }

    @MainActor
    func refreshSession() async throws {
        try await simulateNetwork()
        currentTokens = AuthTokens(accessToken: "mock_refreshed_access_token", refreshToken: "mock_refreshed_refresh_token")
        isAuthenticated = true
    }
}
