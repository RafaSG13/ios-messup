//
//  AuthenticationModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import Observation

@Observable final class AuthenticationModel: AuthenticationModelProtocol {
    var isAuthenticated: Bool = false

    init() {
        self.isAuthenticated = UserDataStore.shared.accessToken != nil
    }

    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        do {
            let response = try await MUClient.shared.send(request, as: LoginResponse.self)
            UserDataStore.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    func logout() async throws {
        UserDataStore.shared.accessToken = nil
        UserDataStore.shared.refreshToken = nil
        self.isAuthenticated = false
    }

    func register(email: String, password: String, name: String) async throws {
        let request = RegisterRequest(email: email, password: password, name: name)
        do {
            let response = try await MUClient.shared.send(request, as: RegisterResponse.self)
            UserDataStore.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }

    func resetPassword() async throws {}

    func refresh() async throws {}
}
