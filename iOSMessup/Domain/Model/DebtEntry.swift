//
//  DebtEntry.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import MUDesignSystem
import SwiftUI

// MARK: - DebtEntryKind

/// What happened between the user and a person. A person's balance is the sum of `sign × amount`: positive means the
/// person owes the user, negative means the user owes the person.
enum DebtEntryKind: String, CaseIterable, Hashable, Sendable, Identifiable {
    case lent
    case borrowed
    case receivedPayment
    case madePayment

    var id: String { rawValue }

    var sign: Double {
        switch self {
        case .lent, .madePayment: 1
        case .borrowed, .receivedPayment: -1
        }
    }

    var isPayment: Bool {
        self == .receivedPayment || self == .madePayment
    }

    var title: LocalizedStringKey {
        switch self {
        case .lent: "I lent money"
        case .borrowed: "I borrowed money"
        case .receivedPayment: "They paid me back"
        case .madePayment: "I paid them back"
        }
    }

    var icon: String {
        switch self {
        case .lent: "arrow.up.right"
        case .borrowed: "arrow.down.left"
        case .receivedPayment, .madePayment: "checkmark.circle"
        }
    }

    var tint: Color {
        switch self {
        case .lent, .borrowed: Color.designSystem.deepBlue
        case .receivedPayment, .madePayment: .accentColor
        }
    }
}

// MARK: - DebtEntry

/// One loan, borrowing or repayment with a person. Debts are real money moving: `cashFlow` feeds the monthly balance.
struct DebtEntry: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var personID: String
    var kind: DebtEntryKind
    var amount: Double
    var date: Date
    var note: String = ""

    var signedAmount: Double { kind.sign * amount }

    /// Effect on the user's money: lending or paying back is money out (negative), borrowing or being paid back is
    /// money in (positive).
    var cashFlow: Double { -signedAmount }
}

// MARK: - Comparable Conformance

extension DebtEntry: Comparable {
    static func < (lhs: DebtEntry, rhs: DebtEntry) -> Bool {
        lhs.date < rhs.date
    }
}

// MARK: - Mocks

extension DebtEntry {
    static var mock = DebtEntry(personID: "mock-alex", kind: .lent, amount: 60, date: Date(), note: "Dinner")

    static var mockArray: [DebtEntry] = [
        DebtEntry(personID: "mock-alex", kind: .lent, amount: 60, date: daysAgo(35), note: "Concert tickets"),
        DebtEntry(personID: "mock-alex", kind: .lent, amount: 25, date: daysAgo(12), note: "Lunch"),
        DebtEntry(personID: "mock-alex", kind: .receivedPayment, amount: 40, date: daysAgo(5)),
        DebtEntry(personID: "mock-sam", kind: .borrowed, amount: 120, date: daysAgo(50), note: "Rent shortfall"),
        DebtEntry(personID: "mock-sam", kind: .madePayment, amount: 70, date: daysAgo(20)),
        DebtEntry(personID: "mock-jordan", kind: .lent, amount: 30, date: daysAgo(70), note: "Train ticket"),
        DebtEntry(personID: "mock-jordan", kind: .receivedPayment, amount: 30, date: daysAgo(40))
    ]

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
