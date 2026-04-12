//
//  iOSMessupApp.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

@main
struct iOSMessupApp: App {
    @State private var status: Status = .idle
    @State private var authService: AuthServiceProtocol = MUEnvironmentConfigurator.authenticationService
    @State private var expenseService: ExpensesServiceProtocol = MUEnvironmentConfigurator.expenseService
    @State private var incomeService: IncomeServiceProtocol = MUEnvironmentConfigurator.incomeService

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .allowsTabReset(triggeredBy: .constant(!authService.isAuthenticated))
                .task { await loadInitialData() }
                .fullScreenCover(isPresented: .constant(!authService.isAuthenticated)) {
                    LandingView()
                }
                .onChange(of: authService.isAuthenticated) { _, newValue in
                    if !newValue { resetAppServices() }
                }
                .environment(\.expenseService, expenseService)
                .environment(\.incomeService, incomeService)
                .environment(\.authService, authService)
        }
    }
}

extension iOSMessupApp {
    func loadInitialData() async {
        do {
            status = .loading
            async let loadExpenses: () = expenseService.loadExpenses()
            async let loadIncomes: () = incomeService.load()

            let _ = try await (loadExpenses, loadIncomes)
            status = .idle
        } catch {
            status = .error(error)
        }
    }

    func resetAppServices() {
        expenseService = MUEnvironmentConfigurator.expenseService
        incomeService = MUEnvironmentConfigurator.incomeService
        authService = MUEnvironmentConfigurator.authenticationService
    }
}
