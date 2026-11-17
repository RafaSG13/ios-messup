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
    @AppStorage(AppCurrency.storageKey) private var currencyCode = AppCurrency.defaultCode
    @State private var expenseService: ExpensesServiceProtocol = MUEnvironmentConfigurator.expenseService
    @State private var incomeService: IncomeServiceProtocol = MUEnvironmentConfigurator.incomeService

    init() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "messup_seed_sample_data"),
           MUEnvironmentConfigurator.current == .local {
            try? DebugSeeder.replaceWithSampleData(in: .shared)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .task { await loadInitialData() }
                .errorAlert(loadError)
                .environment(\.expenseService, expenseService)
                .environment(\.incomeService, incomeService)
                .environment(\.currencyCode, currencyCode)
        }
    }
}

extension iOSMessupApp {
    private var loadError: Binding<(any Error)?> {
        Binding(get: { if case .error(let error) = status { error } else { nil } },
                set: { _ in status = .idle })
    }

    func loadInitialData() async {
        do {
            status = .loading
            try await expenseService.loadExpenses()
            try await incomeService.load()
            status = .idle
        } catch {
            status = .error(error)
        }
    }
}
