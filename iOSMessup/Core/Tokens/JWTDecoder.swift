//
//  JWTDecoder.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 7/4/25.
//

import Foundation

struct JWTDecoder {
    static func decode<T: Decodable>(jwtToken jwt: String, as type: T.Type) -> T? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }

        var base64String = segments[1]
        let requiredLength = 4 * ((base64String.count + 3) / 4)
        base64String = base64String.padding(toLength: requiredLength, withPad: "=", startingAt: 0)
        base64String = base64String.replacingOccurrences(of: "-", with: "+")
                                   .replacingOccurrences(of: "_", with: "/")

        guard let payloadData = Data(base64Encoded: base64String),
              let decoded = try? JSONDecoder().decode(T.self, from: payloadData) else {
            return nil
        }

        return decoded
    }
}
