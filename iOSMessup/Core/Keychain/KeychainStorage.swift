//
//  KeychainStorage.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/6/25.
//

import SwiftUI

@propertyWrapper
struct KeychainStorage {
    private let keychain: KeychainManagerProtocol
    private let key: String


    init(key: String, manager: KeychainManagerProtocol = KeychainManager()) {
        self.key = key
        self.keychain = manager
    }

    var wrappedValue: String? {
        get { keychain.get(key) }
        set {
            guard let newValue else { return }
            keychain.set(newValue, for: key)
        }
    }

    var projectedValue: Binding<String?> {
        Binding(
            get: { [self] in keychain.get(key) },
            set: { [self] newValue in
                guard let newValue else { return }
                keychain.set(newValue, for: key)
            }
        )
    }
}
