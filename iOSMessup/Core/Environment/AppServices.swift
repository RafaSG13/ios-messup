//
//  AppServices.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation

/// The one set of services of the process. The app injects them into the view tree and App Intents use the same
/// instances, so an expense added from Siri or Shortcuts shows up in an open app without reloading.
final class AppServices {
    static let shared = AppServices()

    let expenseService = MUEnvironmentConfigurator.expenseService
    let incomeService = MUEnvironmentConfigurator.incomeService
    let savingsService = MUEnvironmentConfigurator.savingsService
    let budgetService = MUEnvironmentConfigurator.budgetService
    let notificationService = MUEnvironmentConfigurator.notificationService

    let intelligenceService: IntelligenceServiceProtocol

    private init() {
        intelligenceService = MUEnvironmentConfigurator.intelligenceService(expenses: expenseService,
                                                                            incomes: incomeService,
                                                                            savings: savingsService,
                                                                            budget: budgetService)
    }
}
