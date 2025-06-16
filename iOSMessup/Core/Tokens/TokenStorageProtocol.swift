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
