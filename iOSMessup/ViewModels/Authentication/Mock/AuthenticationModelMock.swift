//
//  AuthenticationModelMock.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

final class AuthenticationModelMock: AuthenticationModelProtocol {
    var isAuthenticated: Bool

    var isLoginCalled: Bool = false
    var isLogoutCalled: Bool = false
    var isRegisterCalled: Bool = false
    var isResetPasswordCalled: Bool = false
    var isRefreshCalled: Bool = false

    var loginResponse: Bool = false


    init(isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }

    func login(email: String, password: String) async throws {
        isLoginCalled = true
    }

    func logout() async throws {
        isLogoutCalled = true
    }

    func register(email: String, password: String, name: String) async throws {
        isRegisterCalled = true
    }

    func resetPassword() async throws {
        isResetPasswordCalled = true
    }

    func refresh() async throws {
        isRefreshCalled = true
    }
}
