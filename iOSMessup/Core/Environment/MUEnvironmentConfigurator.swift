//
//  AppEnvironment.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//


import Foundation
import SwiftUI

enum EnvironmentKey: String {
    case dev
    case pro
}

@MainActor
final class MUEnvironmentConfigurator {
    let expenseRepository: ExpenseRepository
    let incomeRepository: IncomeRepository
    let authenticationService: AuthenticationService

    init() {
        let environmentKey = EnvironmentKey(rawValue: UserDefaults.standard.string(forKey: "messup_environment") ?? "dev")

        switch environmentKey {
        case .dev:
            self.authenticationService = AuthenticationService(dataSource: MockAuthenticationDataSource(),
                                                               tokenStorage: InMemoryTokenStorage())
            self.expenseRepository = ExpenseRepository(dataSource: MockExpensesDataSource())
            self.incomeRepository = IncomeRepository(dataSource: IncomeDataSourceMock())
        case .pro:
            self.authenticationService = AuthenticationService(dataSource: LiveAuthenticationDataSource(),
                                                               tokenStorage: UserDefaultsTokenStorage())
            self.expenseRepository = ExpenseRepository(dataSource: ExpensesDataSource())
            self.incomeRepository = IncomeRepository(dataSource: IncomeDataSource())
        case .none:
            fatalError("Unknown app environment")
        }
    }
}
