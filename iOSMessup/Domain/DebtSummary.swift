//
//  DebtSummary.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation

// MARK: - PersonBalance

/// Where the user stands with one person. Positive `balance` means the person owes the user.
struct PersonBalance: Identifiable, Equatable {
    enum State { case owesMe, iOwe, settled }

    let person: Person
    let balance: Double
    let lastActivity: Date?

    var id: String { person.id }

    var state: State {
        if abs(balance) < DebtSummary.settledTolerance { .settled } else if balance > 0 { .owesMe } else { .iOwe }
    }
}

// MARK: - DebtSummary

/// Everyone's balance plus the totals, computed from plain arrays so it is easy to test.
struct DebtSummary: Equatable {
    /// Balances under this are considered settled (money is stored as `Double`).
    static let settledTolerance = 0.005

    /// People with a pending balance first (biggest absolute balance first, ties by name), then settled people by name.
    let balances: [PersonBalance]
    /// Sum of what people owe the user.
    let owedToMe: Double
    /// Sum of what the user owes people.
    let iOwe: Double

    var net: Double { owedToMe - iOwe }

    /// Entries whose `personID` matches nobody are ignored.
    init(people: [Person], entries: [DebtEntry]) {
        var totals: [String: Double] = [:]
        var lastDates: [String: Date] = [:]
        for entry in entries {
            totals[entry.personID, default: 0] += entry.signedAmount
            if let last = lastDates[entry.personID], last >= entry.date { continue }
            lastDates[entry.personID] = entry.date
        }
        let all = people.map { PersonBalance(person: $0, balance: totals[$0.id] ?? 0, lastActivity: lastDates[$0.id]) }
        let pending = all.filter { $0.state != .settled }.sorted {
            abs($0.balance) != abs($1.balance) ? abs($0.balance) > abs($1.balance) : $0.person < $1.person
        }
        let settled = all.filter { $0.state == .settled }.sorted { $0.person < $1.person }
        self.balances = pending + settled
        self.owedToMe = all.filter { $0.state == .owesMe }.reduce(0) { $0 + $1.balance }
        self.iOwe = all.filter { $0.state == .iOwe }.reduce(0) { $0 - $1.balance }
    }

    static func balance(of personID: String, in entries: [DebtEntry]) -> Double {
        entries.filter { $0.personID == personID }.reduce(0) { $0 + $1.signedAmount }
    }
}
