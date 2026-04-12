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

    static var authenticationService: AuthServiceProtocol {
        environment == .dev ? MockAuthService() : AuthService(client: MUClient(),
                                                              tokenStorage: KeyChainTokenStorage())
    }

    static var expenseService: ExpensesServiceProtocol {
        environment == .dev ? MockExpensesService() : ExpensesService(client: MUClient())
    }

    static var incomeService: IncomeServiceProtocol {
        environment == .dev ? MockIncomeService() : IncomeService(client: MUClient())
    }
}
