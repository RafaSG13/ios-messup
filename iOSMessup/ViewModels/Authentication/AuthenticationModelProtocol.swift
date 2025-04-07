//
//  AuthenticationModelProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import SwiftUICore

protocol AuthenticationModelProtocol: AnyObject {
    var isAuthenticated: Bool { get }

    func login(email: String, password: String) async throws
    func logout() async throws
    func register(email: String, password: String, name: String) async throws
    func resetPassword() async throws
    func refresh() async throws
}

extension EnvironmentValues {
    @Entry() var authVM: AuthenticationModelProtocol = AuthenticationModelMock(isAuthenticated: false)
}
