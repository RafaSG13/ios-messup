//
//  TokenRefresh.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 14/4/25.
//

import Foundation

struct TokenRefreshPayload: Encodable {
    let refreshToken: String
}

struct TokenRefreshRequest: MURequest {
    var path: String { "/auth/refresh" }
    var method: HTTPMethod { .post }
    var body: Data?

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    init(refreshToken: String) {
        let payload = TokenRefreshPayload(refreshToken: refreshToken)
        let data = try? JSONEncoder().encode(payload)
        self.body = data
    }
}
