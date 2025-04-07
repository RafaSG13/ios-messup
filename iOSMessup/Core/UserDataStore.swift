//
//  UserDataStore.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

final class UserDataStore {
    private init() {}

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

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: Keys.accessToken) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.accessToken) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: Keys.refreshToken) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.refreshToken) }
    }
}


extension UserDataStore {

    private enum Keys {
        static let accessToken = "MUAccessToken"
        static let refreshToken = "MURefreshToken"
    }
}
