//
//  iOSMessupApp.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

@main
struct iOSMessupApp: App {

    var expenseRepository: ExpenseRepository
    var incomeRepository: IncomeRepository
    var authenticationService: AuthenticationService

    @State private var viewModelLoaded: Bool = false

    init() {
        let environment = MUEnvironmentConfigurator()
        expenseRepository = environment.expenseRepository
        incomeRepository = environment.incomeRepository
        authenticationService = environment.authenticationService
    }

    var body: some Scene {
        WindowGroup {
            if !authenticationService.isAuthenticated {
                LandingView()
                    .environment(\.authenticationService, authenticationService)
            } else {
                initApplication()
                    .task {
                        do {
                            async let loadExpenses: () = expenseRepository.loadExpenses()
                            async let loadIncome: () = incomeRepository.load()

                            try await loadExpenses
                            try await loadIncome
                            viewModelLoaded = true
                        } catch {
                            print("Error loading expenses on app loading: \(error.localizedDescription)")
                        }
                    }
            }
        }
    }

    @ViewBuilder private func initApplication() -> some View {

        if viewModelLoaded == false {
            LoadingScreen()
        } else {
            MainTabBarView()
                .environment(\.expenseRepository, expenseRepository)
                .environment(\.incomeRepository, incomeRepository)
                .environment(\.authenticationService, authenticationService)
        }
    }
}
