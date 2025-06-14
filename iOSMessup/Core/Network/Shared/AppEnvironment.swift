//
//  AppEnvironment.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 14/4/25.
//

import Foundation

enum AppEnvironment {
    static var current: AppEnvironment {
#if DEVELOPMENT
        return .development
#elseif PRODUCTION
        return .production
#else
        fatalError("No environment defined")
#endif
    }

    case development
    case production

    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://localhost:3000")!
        case .production:
            return URL(string: "https://api.tuproduccion.com")!
        }
    }
}
