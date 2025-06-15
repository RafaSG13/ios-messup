//
//  LoginRequest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct LoginRequest: MURequest {
    let email: String
    let password: String

    var path: String { "auth/login" }
    var method: HTTPMethod { .post }
    
    var body: Data? {
        try? JSONEncoder().encode(["email": email, "password": password])
    }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
