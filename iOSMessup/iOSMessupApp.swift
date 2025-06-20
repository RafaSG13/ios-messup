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
    @State private var authenticationService: AuthenticationService = MUEnvironmentConfigurator.authenticationService
    @State private var expenseRepository: ExpenseRepository = MUEnvironmentConfigurator.expenseRepository
    @State private var incomeRepository: IncomeRepository = MUEnvironmentConfigurator.incomeRepository

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .allowsTabReset(triggeredBy: .constant(!authenticationService.isAuthenticated))
                .task { await loadInitialData() }
                .fullScreenCover(isPresented: .constant(!authenticationService.isAuthenticated)) {
                    LandingView()
                }
                .onChange(of: authenticationService.isAuthenticated) { _, newValue in
                    if !newValue {
                        resetAppServices()
                    }
                }
                .environment(\.expenseRepository, expenseRepository)
                .environment(\.incomeRepository, incomeRepository)
                .environment(\.authenticationService, authenticationService)
        }
    }
}

extension iOSMessupApp {
    func loadInitialData() async {
        do {
            status = .loading
            async let loadExpenses: () = expenseRepository.loadExpenses()
            async let loadIncomes: () = incomeRepository.load()

            let _ = try await (loadExpenses, loadIncomes)
            status = .idle
        } catch {
            status = .error(error)
        }
    }

    func resetAppServices() {
        expenseRepository = MUEnvironmentConfigurator.expenseRepository
        incomeRepository = MUEnvironmentConfigurator.incomeRepository
        authenticationService = MUEnvironmentConfigurator.authenticationService
    }
}
