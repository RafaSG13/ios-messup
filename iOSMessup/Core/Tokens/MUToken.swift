//
//  MUToken.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct MUToken: Codable {
    let name: String?
    let email: String?
    let userImage: String?
    let userId: String?
    let exp: TimeInterval?       // Expiration (UNIX timestamp)
    let iat: TimeInterval?       // Issued at
    let iss: String?             // Issuer
    let sub: String?             // Subject

    var expirationDate: Date? {
        guard let exp = exp else { return nil }
        return Date(timeIntervalSince1970: exp)
    }

    var issuedDate: Date? {
        guard let iat = iat else { return nil }
        return Date(timeIntervalSince1970: iat)
    }

    var isExpired: Bool {
        guard let expiration = expirationDate else { return true }
        return Date() > expiration
    }
}


extension MUToken {
    static func from(jwtToken token: String) -> MUToken? {
        return JWTDecoder.decode(jwtToken: token, as: MUToken.self)
    }
}
