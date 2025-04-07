//
//  MUAPIError.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct MUAPIError: Decodable, LocalizedError {
    let error: String
    let code: Int?

    var errorDescription: String? {
        return error
    }
}
