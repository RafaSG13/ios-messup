//
//  AuthenticationModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import SwiftUI
import Observation

enum AuthError: Error {
    case invalidCredentials
    case userAlreadyExists
    case networkError(Error)
    case tokenRefreshFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError: "No user found with that email address."
        case .userAlreadyExists: "An account with this email address already exists."
        case .invalidCredentials: "Incorrect email or password."
        case .tokenRefreshFailed: ""
        case .unknown: "Unknown error."
        }
    }
}

extension EnvironmentValues {
    @Entry var authenticationService: AuthenticationService = AuthenticationService(dataSource: MockAuthenticationDataSource(),
                                                                                    tokenStorage: InMemoryTokenStorage())
}

@Observable
final class AuthenticationService {
    private(set) var isAuthenticated: Bool

    private let dataSource: AuthenticationDataSourceProtocol
    private let tokenStorage: TokenStorageProtocol

    init(dataSource: AuthenticationDataSourceProtocol, tokenStorage: TokenStorageProtocol) {
        self.dataSource = dataSource
        self.tokenStorage = tokenStorage
        self.isAuthenticated = tokenStorage.getRefreshToken() != nil
    }

    @MainActor
    func login(email: String, password: String) async throws {
        let tokens = try await dataSource.login(email: email, password: password)
        tokenStorage.save(tokens: tokens)
        self.isAuthenticated = true
    }

    @MainActor
    func logout() {
        tokenStorage.clearTokens()
        self.isAuthenticated = false
    }

    @MainActor
    func register(email: String, password: String, name: String) async throws {
        let tokens = try await dataSource.register(email: email, password: password, name: name)
        tokenStorage.save(tokens: tokens)
        self.isAuthenticated = true
    }

    @MainActor
    func resetPassword(for email: String) async throws {
        try await dataSource.resetPassword(for: email)
    }

    @MainActor
    func refreshSession() async throws {
        guard let refreshToken = tokenStorage.getRefreshToken() else {
            throw AuthError.tokenRefreshFailed
        }
        let tokens = try await dataSource.refreshToken(using: refreshToken)
        tokenStorage.save(tokens: tokens)
        self.isAuthenticated = true
    }
}
