//
//  IncomeGoal.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//
import SwiftUI

struct SavingGoal: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var completionDate: CompletionDate
    var amount: Double
    var savingCategory: SavingCategory
}

// MARK: - Mock

extension SavingGoal {
    static var mock = SavingGoal(name: "Vacation in Europe",
                                 completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 180)), // 6 months from now
                                 amount: 5000.0,
                                 savingCategory: .vacation)
    static var mockArray: [SavingGoal] = [
          SavingGoal(name: "Vacation in Europe", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 180)), amount: 5000.0, savingCategory: .vacation),
          SavingGoal(name: "Buy a New Car", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 365)), amount: 20000.0, savingCategory: .assetPurchase),
          SavingGoal(name: "Emergency Fund", completionDate: .undefined, amount: 10000.0, savingCategory: .emergencyFund),
          SavingGoal(name: "Home Renovation", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 90)), amount: 15000.0, savingCategory: .homeRenovation),
          SavingGoal(name: "Child's Education Fund", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 365 * 5)), amount: 50000.0, savingCategory: .education),
          SavingGoal(name: "Retirement Fund", completionDate: .undefined, amount: 250000.0, savingCategory: .retirement),
          SavingGoal(name: "Start a Business", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 730)), amount: 100000.0, savingCategory: .entrepreneurship),
          SavingGoal(name: "Wedding Celebration", completionDate: .fixed(Date().addingTimeInterval(60 * 60 * 24 * 365 / 2)), amount: 30000.0, savingCategory: .bigEvent)
      ]
}

// MARK: - Completion Date

enum CompletionDate: Equatable, Hashable {
    case undefined
    case fixed(Date)

    var textValue: String {
        switch self {
        case .undefined: return "Undefined"
        case .fixed(let date): return date.categoryFormattedDate()
        }
    }
}

// MARK: - Saving Category

enum SavingCategory: String, CaseIterable {
    case vacation = "Vacation"
    case assetPurchase = "Asset Purchase"
    case emergencyFund = "Emergency Fund"
    case liquidity = "Liquidity"
    case education = "Education"
    case retirement = "Retirement"
    case debtRepayment = "Debt Repayment"
    case familySupport = "Family Support"
    case homeRenovation = "Home Renovation"
    case healthCare = "Health Care"
    case charity = "Charity"
    case bigEvent = "Big Event"
    case entrepreneurship = "Entrepreneurship"
    case personalDevelopment = "Personal Development"

    var icon: String {
        switch self {
        case .vacation: return "sun.haze.fill"
        case .assetPurchase: return "house.fill"
        case .emergencyFund: return "shield.fill"
        case .liquidity: return "drop.fill"
        case .education: return "book.fill"
        case .retirement: return "person.crop.circle.fill.badge.checkmark"
        case .debtRepayment: return "dollarsign.circle.fill"
        case .familySupport: return "person.2.fill"
        case .homeRenovation: return "paintbrush.fill"
        case .healthCare: return "cross.case.fill"
        case .charity: return "heart.fill"
        case .bigEvent: return "calendar.circle.fill"
        case .entrepreneurship: return "lightbulb.fill"
        case .personalDevelopment: return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .vacation: return .yellow
        case .assetPurchase: return .teal
        case .emergencyFund: return .red
        case .liquidity: return .cyan
        case .education: return .purple
        case .retirement: return .orange
        case .debtRepayment: return .green
        case .familySupport: return .blue
        case .homeRenovation: return .brown
        case .healthCare: return .pink
        case .charity: return .red
        case .bigEvent: return .indigo
        case .entrepreneurship: return .orange
        case .personalDevelopment: return .purple
        }
    }
}
