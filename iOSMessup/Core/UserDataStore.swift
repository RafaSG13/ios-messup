//
//  UserDataStore.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

final class UserDataStore {
    private init() {
        guard let accessToken = UserDefaults.standard.string(forKey: TokenKeys.accessToken) else { return }
        saveUserData(from: accessToken)
    }

    static let shared = UserDataStore()

    var userName: String?
    var userEmail: String?
    var userImage: String?
    var userId: String?

    func saveUserData(from token: String) {
        guard let muToken = MUToken.from(jwtToken: token) else { return }
        userName = muToken.name
        userEmail = muToken.email
        userImage = muToken.userImage
        userId = muToken.userId
    }

    func removeUserData() {
        userName = nil
        userEmail = nil
        userImage = nil
        userId = nil
    }
}
