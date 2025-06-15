//
//  AuthenticationModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import SwiftUICore
import Observation

enum AuthError: Error {
    case invalidCredentials
    case userAlreadyExists
    case networkError(Error)
    case tokenRefreshFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "No se encontró un usuario con ese correo electrónico."
        case .userAlreadyExists:
            return "Ya existe una cuenta con este correo electrónico."
        case .invalidCredentials:
            return "Correo electrónico o contraseña incorrectos."
        case .tokenRefreshFailed:
            return ""
        case .unknown:
            return "Error desconocido."
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
