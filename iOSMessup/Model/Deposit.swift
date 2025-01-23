//
//  SavingDeposit.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

struct Deposit: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var concept: String
    var amount: Double
    var date: Date
    var foundingSource: FoundingSource
}

// MARK: - FoundingSource

enum FoundingSource: String, CaseIterable, Hashable {
    case salary = "Salary"
    case freelance = "Freelance"
    case investments = "Investments"
    case rentalIncome = "Rental Income"
    case businessProfits = "Business Profits"
    case gifts = "Gifts"
    case inheritance = "Inheritance"
    case savings = "Savings"
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
        case .savings: return "banknote.fill"
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
        case .savings: return .yellow
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
