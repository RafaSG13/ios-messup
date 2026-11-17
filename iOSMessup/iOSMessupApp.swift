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
    @State private var expenseService: ExpensesServiceProtocol = MUEnvironmentConfigurator.expenseService
    @State private var incomeService: IncomeServiceProtocol = MUEnvironmentConfigurator.incomeService

    init() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "messup_seed_sample_data"),
           MUEnvironmentConfigurator.current == .local {
            MainActor.assumeIsolated {
                try? DebugSeeder.replaceWithSampleData(in: .shared)
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .task { await loadInitialData() }
                .environment(\.expenseService, expenseService)
                .environment(\.incomeService, incomeService)
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
}
