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

// El gestor de nuestro entorno
@MainActor
final class MUEnvironmentConfigurator {
    let expenseRepository: ExpenseRepository
    let savingViewModel: SavingViewModel
    let authenticationService: AuthenticationService

    init() {
        let environmentKey = EnvironmentKey(rawValue: UserDefaults.standard.string(forKey: "messup_environment") ?? "dev")

        switch environmentKey {
        case .dev:
            self.authenticationService = AuthenticationService(dataSource: MockAuthenticationDataSource(),
                                                               tokenStorage: InMemoryTokenStorage())
            self.expenseRepository = ExpenseRepository(dataSource: MockExpensesDataSource())
            self.savingViewModel = SavingViewModel(dataSource: SavingDataSource())
        case .pro:
            self.authenticationService = AuthenticationService(dataSource: LiveAuthenticationDataSource(),
                                                               tokenStorage: UserDefaultsTokenStorage())
            self.expenseRepository = ExpenseRepository(dataSource: ExpensesDataSource())
            self.savingViewModel = SavingViewModel(dataSource: SavingDataSource())
        case .none:
            fatalError("Unknown app environment")
        }
    }
}
