//
//  AuthServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation
import SwiftUI

protocol AuthServiceProtocol: AnyObject {
    var isAuthenticated: Bool { get }

    @MainActor func login(email: String, password: String) async throws
    @MainActor func logout()
    @MainActor func register(email: String, password: String, name: String) async throws
    @MainActor func resetPassword(for email: String) async throws
    @MainActor func refreshSession() async throws
}

extension EnvironmentValues {
    @Entry var authService: AuthServiceProtocol = MockAuthService()
}
