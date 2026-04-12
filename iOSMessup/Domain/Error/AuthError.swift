//
//  AuthError.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 12/4/26.
//

import Foundation

enum AuthError: Error {
    case invalidCredentials
    case userAlreadyExists
    case networkError(Error)
    case tokenRefreshFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError: "No user found with that email address."
        case .userAlreadyExists: "An account with this email address already exists."
        case .invalidCredentials: "Incorrect email or password."
        case .tokenRefreshFailed: ""
        case .unknown: "Unknown error."
        }
    }
}