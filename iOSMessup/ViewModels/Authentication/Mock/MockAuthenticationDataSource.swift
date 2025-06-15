//
//  MockAuthenticationDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//


import Foundation

class MockAuthenticationDataSource: AuthenticationDataSourceProtocol {
    enum MockError: Error { case operationFailed }
    
    var shouldSucceed: Bool
    var responseDelay: TimeInterval
    
    init(shouldSucceed: Bool = true, responseDelay: TimeInterval = 1.0) {
        self.shouldSucceed = shouldSucceed
        self.responseDelay = responseDelay
    }
    
    private func simulateResponse() async throws {
        try await Task.sleep(for: .seconds(responseDelay))
        if !shouldSucceed {
            throw MockError.operationFailed
        }
    }
    
    func login(email: String, password: String) async throws -> AuthTokens {
        try await simulateResponse()
        return AuthTokens(accessToken: "mock_access_token_login", refreshToken: "mock_refresh_token_login")
    }

    func register(email: String, password: String, name: String) async throws -> AuthTokens {
        try await simulateResponse()
        return AuthTokens(accessToken: "mock_access_token_register", refreshToken: "mock_refresh_token_register")
    }
    
    func resetPassword(for email: String) async throws {
        try await simulateResponse()
    }
    
    func refreshToken(using token: String) async throws -> AuthTokens {
        try await simulateResponse()
        return AuthTokens(accessToken: "mock_refreshed_access_token", refreshToken: "mock_refreshed_refresh_token")
    }
}
