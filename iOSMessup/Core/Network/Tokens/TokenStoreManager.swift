//
//  TokenStoreManager.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 14/4/25.
//

import KeychainAccess

protocol TokenStore {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    func cleanTokens()
}


final class TokenStoreManager: TokenStore {
    static let shared = TokenStoreManager()
    private let service = "com.rafasg13.iOSMessup"
    private init() {}

    var accessToken: String? {
        get { try? Keychain(service: service).get(TokenKeys.accessToken) }
        set {
            guard let newValue else { return }
            try? Keychain(service: service).set(newValue, key: TokenKeys.accessToken)
        }
    }

    var refreshToken: String? {
        get { try? Keychain(service: service).get(TokenKeys.refreshToken) }
        set {
            guard let newValue else { return }
            try? Keychain(service: service).set(newValue, key: TokenKeys.refreshToken)
        }
    }

    func cleanTokens() {
        try? Keychain(service: service).remove(TokenKeys.accessToken)
        try? Keychain(service: service).remove(TokenKeys.refreshToken)
    }
}

