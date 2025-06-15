//
//  AuthenticationModelProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct AuthTokens {
    let accessToken: String
    let refreshToken: String
}

protocol AuthenticationDataSourceProtocol {
    func login(email: String, password: String) async throws -> AuthTokens
    func register(email: String, password: String, name: String) async throws -> AuthTokens
    func resetPassword(for email: String) async throws
    func refreshToken(using token: String) async throws -> AuthTokens
}
