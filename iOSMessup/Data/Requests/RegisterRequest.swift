//
//  RegisterRequest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct RegisterRequest: MURequest {
    let email: String
    let password: String
    let name: String

    var path: String { "auth/register" }
    var method: HTTPMethod { .post }

    var body: Data? {
        try? JSONEncoder().encode(["email": email, "password": password, "name": name])
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
