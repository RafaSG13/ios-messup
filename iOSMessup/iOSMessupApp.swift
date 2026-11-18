//
//  iOSMessupApp.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import UserNotifications

@main
struct iOSMessupApp: App {
    @State private var status: Status = .idle
    @AppStorage(AppCurrency.storageKey) private var currencyCode = AppCurrency.defaultCode
    @State private var expenseService: ExpensesServiceProtocol = AppServices.shared.expenseService
    @State private var incomeService: IncomeServiceProtocol = AppServices.shared.incomeService
    @State private var savingsService: SavingsServiceProtocol = AppServices.shared.savingsService
    @State private var budgetService: BudgetServiceProtocol = AppServices.shared.budgetService
    @State private var notificationService: NotificationServiceProtocol = AppServices.shared.notificationService

    init() {
        UNUserNotificationCenter.current().delegate = NotificationPresenter.shared
        #if DEBUG
        if MUEnvironmentConfigurator.current == .local {
            try? DebugSeeder.seedOnLaunch(in: .shared)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .budgetAlerts()
                .task { await loadInitialData() }
                .errorAlert(loadError)
                .environment(\.expenseService, expenseService)
                .environment(\.incomeService, incomeService)
                .environment(\.savingsService, savingsService)
                .environment(\.budgetService, budgetService)
                .environment(\.notificationService, notificationService)
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
            try await savingsService.load()
            try await budgetService.load()
            status = .idle
        } catch {
            status = .error(error)
        }
    }
}
