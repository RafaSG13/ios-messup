//
//  iOSMessupApp.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

@main
struct iOSMessupApp: App {
    var expenseViewModel = ExpenseViewModel(dataSource: ExpensesDataSource())
    var savingViewModel = SavingViewModel(dataSource: SavingDataSource())
    var authenticationViewModel = AuthenticationModel()

    @State private var viewModelLoaded: Bool = false

    var body: some Scene {
        WindowGroup {
            if !authenticationViewModel.isAuthenticated {
                LandingView()
                    .environment(\.authVM, authenticationViewModel)
            } else {
                initApplication()
                    .task {
                        guard authenticationViewModel.isAuthenticated else { return }
                        do {
                            async let loadExpenses: () = expenseViewModel.loadExpenses()
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
                .environment(\.expenseVM, expenseViewModel)
                .environment(\.savingVM, savingViewModel)
                .environment(\.authVM, authenticationViewModel)
        }
    }
}
