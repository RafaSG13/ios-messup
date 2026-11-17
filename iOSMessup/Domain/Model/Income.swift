//
//  Income.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

/// Money coming in (salary, freelance, gifts...). It is independent of saving goals: a goal is funded by
/// explicit `Contribution`s, and the monthly balance is income − expenses − contributions.
struct Income: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var concept: String
    var amount: Double
    var date: Date
    var source: IncomeSource
}

// MARK: - Comparable Conformance

extension Income: Comparable {
    static func < (lhs: Income, rhs: Income) -> Bool {
        return lhs.date < rhs.date
    }
}

// MARK: Mocks

extension Income {
    static var mock: Income = Income(concept: "Monthly Salary", amount: 3000.0, date: Date(), source: .salary)

    static var mockArray: [Income] = [
        Income(concept: "Freelance Payment", amount: 1200.0, date: daysAgo(2), source: .freelance),
        Income(concept: "Bonus", amount: 500.0, date: daysAgo(6), source: .bonuses),
        Income(concept: "Stock Dividends", amount: 250.0, date: daysAgo(11), source: .investments),
        Income(concept: "Gift", amount: 150.0, date: daysAgo(16), source: .gifts),
        Income(concept: "Passive Income", amount: 800.0, date: daysAgo(4), source: .passiveIncome)
    ]

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}

// MARK: - IncomeSource

enum IncomeSource: String, CaseIterable, Hashable, Equatable {
    case salary = "Salary"
    case freelance = "Freelance"
    case investments = "Investments"
    case rentalIncome = "Rental Income"
    case businessProfits = "Business Profits"
    case gifts = "Gifts"
    case inheritance = "Inheritance"
    case bonuses = "Bonuses"
    case taxRefund = "Tax Refund"
    case passiveIncome = "Passive Income"
    case sellingAssets = "Selling Assets"
    case sideHustle = "Side Hustle"
    case governmentBenefits = "Government Benefits"
    case other = "Other"

    var icon: String {
        switch self {
        case .salary: return "banknote"
        case .freelance: return "pencil.and.outline"
        case .investments: return "chart.bar.xaxis"
        case .rentalIncome: return "house"
        case .businessProfits: return "briefcase"
        case .gifts: return "gift"
        case .inheritance: return "scroll"
        case .bonuses: return "sparkles"
        case .taxRefund: return "arrowshape.turn.up.left.circle"
        case .passiveIncome: return "waveform.path.ecg"
        case .sellingAssets: return "cart.fill"
        case .sideHustle: return "hammer.fill"
        case .governmentBenefits: return "building.columns.fill"
        case .other: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .salary: return .green
        case .freelance: return .blue
        case .investments: return .purple
        case .rentalIncome: return .teal
        case .businessProfits: return .orange
        case .gifts: return .pink
        case .inheritance: return .brown
        case .bonuses: return .mint
        case .taxRefund: return .indigo
        case .passiveIncome: return .cyan
        case .sellingAssets: return .red
        case .sideHustle: return .gray
        case .governmentBenefits: return .primary
        case .other: return .secondary
        }
    }
}
