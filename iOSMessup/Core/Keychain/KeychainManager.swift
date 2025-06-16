//
//  KeychainManager.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/6/25.
//

import KeychainSwift

protocol KeychainManagerProtocol {
    func set(_ value: String, for key: String)
    func get(_ key: String) -> String?
    func remove(_ key: String)
    func removeAll()
}

class KeychainManager: KeychainManagerProtocol {
    private let keychain = KeychainSwift()

    func set(_ value: String, for key: String) {
        keychain.set(value, forKey: key)
    }

    func get(_ key: String) -> String? {
        keychain.get(key)
    }

    func remove(_ key: String) {
        keychain.delete(key)
    }

    func removeAll() {
        keychain.clear()
    }
}
