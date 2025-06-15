//
//  RegisterResponse.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//


struct RegisterResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
