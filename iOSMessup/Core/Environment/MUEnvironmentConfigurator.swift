//
//  AppEnvironment.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 15/6/25.
//


import Foundation
import SwiftUI

final class MUEnvironmentConfigurator {

    private enum EnvironmentKey: String {
        case dev
        case pro
    }

    private static var environment: EnvironmentKey {
        EnvironmentKey(rawValue: UserDefaults.standard.string(forKey: "messup_environment") ?? "dev") ?? .dev
    }

    static var authenticationService: AuthenticationService {
        if environment == .dev {
            return AuthenticationService(dataSource: MockAuthenticationDataSource(),
                                        tokenStorage: InMemoryTokenStorage())
        } else {
            return AuthenticationService(dataSource: LiveAuthenticationDataSource(),
                                         tokenStorage: KeyChainTokenStorage())
        }
    }

    static var expenseRepository: ExpenseRepository {
        if environment == .dev {
            return ExpenseRepository(dataSource: ExpensesDataSourceMock())
        } else {
            return ExpenseRepository(dataSource: ExpensesDataSource())
        }
    }

    static var incomeRepository: IncomeRepository {
        if environment == .dev {
            return IncomeRepository(dataSource: IncomeDataSourceMock())
        } else {
            return IncomeRepository(dataSource: IncomeDataSource())
        }
    }
}
