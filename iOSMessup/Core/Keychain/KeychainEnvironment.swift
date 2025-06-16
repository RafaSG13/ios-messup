//
//  KeychainEnvironment.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/6/25.
//

import SwiftUICore

extension EnvironmentValues {
    @Entry var keychainManager: KeychainManagerProtocol = KeychainManager()
}
