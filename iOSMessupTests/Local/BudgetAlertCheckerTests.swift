//
//  BudgetAlertCheckerTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct BudgetAlertCheckerTests {
    private let budget = Budget(monthlyLimit: 1000)
    private let now = Date.now

    /// An isolated, empty defaults domain per test so marks never leak between tests.
    private func makeDefaults(alertsEnabled: Bool = true) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "BudgetAlertCheckerTests-\(UUID().uuidString)")!
        defaults.set(alertsEnabled, forKey: NotificationPreferences.budgetAlertsKey)
        return defaults
    }

    private func expense(_ amount: Double) -> Expense {
        Expense(name: "Test", amount: amount, date: now, paymentMethod: .cash, category: .food)
    }

    @Test func optedOutUserGetsNothing() async {
        let notifications = MockNotificationService()
        let level = await BudgetAlertChecker.check(expenses: [expense(900)], budget: budget,
                                                   notifications: notifications, currencyCode: "EUR",
                                                   defaults: makeDefaults(alertsEnabled: false), now: now)
        #expect(level == nil)
        #expect(notifications.postedAlerts.isEmpty)
    }

    @Test func withoutBudgetThereIsNothingToCheck() async {
        let notifications = MockNotificationService()
        await BudgetAlertChecker.check(expenses: [expense(5000)], budget: nil, notifications: notifications,
                                       currencyCode: "EUR", defaults: makeDefaults(), now: now)
        #expect(notifications.postedAlerts.isEmpty)
    }

    @Test func crossingEachThresholdPostsOnceEvenWhenCheckedRepeatedly() async {
        let notifications = MockNotificationService()
        let defaults = makeDefaults()
        for expenses in [[expense(500)], [expense(850)], [expense(850)], [expense(850), expense(200)],
                         [expense(850), expense(200)]] {
            await BudgetAlertChecker.check(expenses: expenses, budget: budget, notifications: notifications,
                                           currencyCode: "EUR", defaults: defaults, now: now)
        }
        #expect(notifications.postedAlerts == [
            .init(level: .warning, spent: 850, limit: 1000),
            .init(level: .over, spent: 1050, limit: 1000)
        ])
    }

    @Test func onlyTheCurrentMonthCounts() async {
        let notifications = MockNotificationService()
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        let old = Expense(name: "Old", amount: 5000, date: lastMonth, paymentMethod: .cash, category: .food)
        await BudgetAlertChecker.check(expenses: [old, expense(100)], budget: budget, notifications: notifications,
                                       currencyCode: "EUR", defaults: makeDefaults(), now: now)
        #expect(notifications.postedAlerts.isEmpty)
    }
}

// MARK: - AddExpenseIntent

struct AddExpenseIntentTests {
    private func intent(amount: Double, name: String) -> AddExpenseIntent {
        var intent = AddExpenseIntent()
        intent.amount = amount
        intent.name = name
        intent.category = .food
        intent.paymentMethod = .debitCard
        return intent
    }

    @Test func recordsTheExpenseWithTrimmedNameAndChosenFields() async throws {
        let service = MockExpensesService(initialExpenses: [], delay: 0)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let saved = try await intent(amount: 12.5, name: "  Coffee ").record(in: service, now: date)
        #expect(service.expenses == [saved])
        #expect(saved.name == "Coffee")
        #expect(saved.amount == 12.5)
        #expect(saved.date == date)
        #expect(saved.category == .food)
        #expect(saved.paymentMethod == .debitCard)
    }

    @Test(arguments: [0.0, -5.0])
    func rejectsNonPositiveAmounts(amount: Double) async {
        let service = MockExpensesService(initialExpenses: [], delay: 0)
        await #expect(throws: AddExpenseIntentError.self) {
            try await intent(amount: amount, name: "Coffee").record(in: service)
        }
        #expect(service.expenses.isEmpty)
    }

    @Test func rejectsBlankNames() async {
        let service = MockExpensesService(initialExpenses: [], delay: 0)
        await #expect(throws: AddExpenseIntentError.self) {
            try await intent(amount: 3, name: "   ").record(in: service)
        }
        #expect(service.expenses.isEmpty)
    }
}
