//
//  AuthenticationModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import Observation

//TODO: Create datasources, token datasource, user datasource, etc.
//TODO: Error Management

@Observable final class AuthenticationModel: AuthenticationModelProtocol {
    var isAuthenticated: Bool

    init() {
        self.isAuthenticated = UserDefaults.standard.object(forKey: TokenKeys.refreshToken) != nil
    }

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        do {
            guard let baseURL = URL(string: "http://localhost:3000") else { return }
            let response = try await MUClient(baseURL: baseURL).send(request, as: LoginResponse.self)
            saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
            isAuthenticated = true
        } catch {
            throw AuthError.invalidCredentials
        }
    }

    func logout() {
        removeTokens()
        isAuthenticated = false
    }

    func register(email: String, password: String, name: String) async throws {
        let request = RegisterRequest(email: email, password: password, name: name)
        do {
            guard let baseURL = URL(string: "http://localhost:3000") else { return }
            let response = try await MUClient(baseURL: baseURL).send(request, as: RegisterResponse.self)
            saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
            isAuthenticated = true
        } catch {
            throw AuthError.userAlreadyExists
        }
    }

    func resetPassword() async throws {}

    func refresh() async throws {}

    func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: TokenKeys.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: TokenKeys.refreshToken)
        UserDataStore.shared.saveUserData(from: accessToken)
    }

    func removeTokens() {
        UserDefaults.standard.removeObject(forKey: TokenKeys.accessToken)
        UserDefaults.standard.removeObject(forKey: TokenKeys.refreshToken)
        UserDataStore.shared.removeUserData()
    }
}
