//
//  MUEnvironmentConfigurator.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//


import Foundation
import SwiftUI

final class MUEnvironmentConfigurator {

    enum Environment: String {
        case mock
        case local
    }

    /// Reads UserDefaults `messup_environment` (launch arg `-messup_environment mock`). Anything else is `.local`.
    static var current: Environment {
        UserDefaults.standard.string(forKey: "messup_environment").flatMap(Environment.init(rawValue:)) ?? .local
    }

    static var expenseService: ExpensesServiceProtocol {
        switch current {
        case .mock: MockExpensesService()
        case .local: ExpensesService(store: .shared)
        }
    }

    static var incomeService: IncomeServiceProtocol {
        switch current {
        case .mock: MockIncomeService()
        case .local: IncomeService(store: .shared)
        }
    }

    static var savingsService: SavingsServiceProtocol {
        switch current {
        case .mock: MockSavingsService()
        case .local: SavingsService(store: .shared)
        }
    }

    static var budgetService: BudgetServiceProtocol {
        switch current {
        case .mock: MockBudgetService()
        case .local: BudgetService(store: .shared)
        }
    }
}
