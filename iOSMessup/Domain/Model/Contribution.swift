//
//  Contribution.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

/// Money set aside for the saving goal. Goal progress is the sum of contributions, and contributions reduce the
/// monthly balance (balance = income − expenses − contributions).
struct Contribution: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var amount: Double
    var date: Date
    var note: String = ""
}

// MARK: - Comparable Conformance

extension Contribution: Comparable {
    static func < (lhs: Contribution, rhs: Contribution) -> Bool {
        lhs.date < rhs.date
    }
}

// MARK: - Mocks

extension Contribution {
    static var mock = Contribution(amount: 300, date: Date(), note: "Monthly saving")

    static var mockArray: [Contribution] = [
        Contribution(amount: 300, date: daysAgo(3), note: "Monthly saving"),
        Contribution(amount: 300, date: daysAgo(33), note: "Monthly saving"),
        Contribution(amount: 150, date: daysAgo(48), note: "Extra"),
        Contribution(amount: 300, date: daysAgo(63), note: "Monthly saving")
    ]

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
