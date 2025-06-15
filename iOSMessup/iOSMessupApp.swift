//
//  iOSMessupApp.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

@main
struct iOSMessupApp: App {
//    var expenseRepository = ExpenseRepository(dataSource: ExpensesDataSource())
//    var savingViewModel = SavingViewModel(dataSource: SavingDataSource())
//    var authenticationService = AuthenticationService(dataSource: LiveAuthenticationDataSource(),
//                                                        tokenStorage: UserDefaultsTokenStorage())
//

    var expenseRepository = ExpenseRepository(dataSource: MockExpensesDataSource())
    var savingViewModel = SavingViewModel(dataSource: SavingDataSource())
    var authenticationService = AuthenticationService(dataSource: MockAuthenticationDataSource(),
                                                        tokenStorage: InMemoryTokenStorage())

    @State private var viewModelLoaded: Bool = false

    var body: some Scene {
        WindowGroup {
            if !authenticationService.isAuthenticated {
                LandingView()
                    .environment(\.authenticationService, authenticationService)
            } else {
                initApplication()
                    .task {
                        guard authenticationService.isAuthenticated else { return }
                        do {
                            async let loadExpenses: () = expenseRepository.loadExpenses()
                            async let loadSavings: () = savingViewModel.load()

                            try await loadExpenses
                            try await loadSavings
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
                .environment(\.savingVM, savingViewModel)
                .environment(\.authenticationService, authenticationService)
        }
    }
}
