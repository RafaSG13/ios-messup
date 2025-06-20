//
//  Status.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/6/25.
//


enum Status: Equatable {
    case idle
    case loading
    case error(Error)

    static func == (lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
