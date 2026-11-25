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
    @State private var debtsService: DebtsServiceProtocol = AppServices.shared.debtsService
    @State private var contactsService: ContactsServiceProtocol = AppServices.shared.contactsService
    @State private var dictationService: DictationServiceProtocol = AppServices.shared.dictationService
    @State private var budgetService: BudgetServiceProtocol = AppServices.shared.budgetService
    @State private var notificationService: NotificationServiceProtocol = AppServices.shared.notificationService
    @State private var intelligenceService: IntelligenceServiceProtocol = AppServices.shared.intelligenceService

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
                .environment(\.debtsService, debtsService)
                .environment(\.contactsService, contactsService)
                .environment(\.dictationService, dictationService)
                .environment(\.budgetService, budgetService)
                .environment(\.notificationService, notificationService)
                .environment(\.intelligenceService, intelligenceService)
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
            try await budgetService.load()
            try await debtsService.load()
            status = .idle
        } catch {
            status = .error(error)
        }
    }
}
