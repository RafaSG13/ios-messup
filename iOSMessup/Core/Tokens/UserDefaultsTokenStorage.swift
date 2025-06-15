//
//  UserDefaultsTokenStorage.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//

import Foundation

protocol TokenStorageProtocol {
    func save(tokens: AuthTokens)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearTokens()
}

class UserDefaultsTokenStorage: TokenStorageProtocol {
    func save(tokens: AuthTokens) {
        UserDefaults.standard.set(tokens.accessToken, forKey: TokenKeys.accessToken)
        UserDefaults.standard.set(tokens.refreshToken, forKey: TokenKeys.refreshToken)
    }

    func getAccessToken() -> String? {
        UserDefaults.standard.string(forKey: TokenKeys.accessToken)
    }

    func getRefreshToken() -> String? {
        UserDefaults.standard.string(forKey: TokenKeys.refreshToken)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: TokenKeys.accessToken)
        UserDefaults.standard.removeObject(forKey: TokenKeys.refreshToken)
    }
}
