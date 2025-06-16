//
//  TokenStorageProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/6/25.
//


//
//  UserDefaultsTokenStorage.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//

import Foundation

class KeyChainTokenStorage: TokenStorageProtocol {
    private let manager = KeychainManager()

    func save(tokens: AuthTokens) {
        manager.set(tokens.accessToken, for: TokenKeys.accessToken)
        manager.set(tokens.refreshToken, for: TokenKeys.refreshToken)
    }

    func getAccessToken() -> String? {
        manager.get(TokenKeys.accessToken)
    }

    func getRefreshToken() -> String? {
        manager.get(TokenKeys.refreshToken)
    }

    func clearTokens() {
        manager.remove(TokenKeys.accessToken)
        manager.remove(TokenKeys.refreshToken)
    }
}
