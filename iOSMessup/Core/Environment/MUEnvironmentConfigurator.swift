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

    static var debtsService: DebtsServiceProtocol {
        switch current {
        case .mock: MockDebtsService()
        case .local: DebtsService(store: .shared)
        }
    }

    static var contactsService: ContactsServiceProtocol {
        switch current {
        case .mock: MockContactsService()
        case .local: ContactsService()
        }
    }

    static var dictationService: DictationServiceProtocol {
        switch current {
        case .mock: MockDictationService()
        case .local: DictationService()
        }
    }

    static var budgetService: BudgetServiceProtocol {
        switch current {
        case .mock: MockBudgetService()
        case .local: BudgetService(store: .shared)
        }
    }

    static var notificationService: NotificationServiceProtocol {
        switch current {
        case .mock: MockNotificationService()
        case .local: NotificationService()
        }
    }

    static func intelligenceService(expenses: ExpensesServiceProtocol,
                                    incomes: IncomeServiceProtocol,
                                    debts: DebtsServiceProtocol,
                                    budget: BudgetServiceProtocol) -> IntelligenceServiceProtocol {
        switch current {
        case .mock: MockIntelligenceService()
        case .local: IntelligenceService(expenseService: expenses,
                                         incomeService: incomes,
                                         debtsService: debts,
                                         budgetService: budget)
        }
    }
}
