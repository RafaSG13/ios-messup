//
//  KeychainEnvironment.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/6/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var keychainManager: KeychainManagerProtocol = KeychainManager()
}
