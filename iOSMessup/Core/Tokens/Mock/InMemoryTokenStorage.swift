//
//  InMemoryTokenStorage.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//


class InMemoryTokenStorage: TokenStorageProtocol {
    private var accessToken: String?
    private var refreshToken: String?

    init(accessToken: String? = nil, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func save(tokens: AuthTokens) {
        self.accessToken = tokens.accessToken
        self.refreshToken = tokens.refreshToken
    }

    func getAccessToken() -> String? {
        return accessToken
    }

    func getRefreshToken() -> String? {
        return refreshToken
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}
