//
//  BudgetAlertChecker.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation

/// Decides whether the current month's spending needs a budget notification and delivers it. Called by the UI
/// whenever expenses or the budget change and by the Siri/Shortcuts intent (which can run with no UI at all).
/// The "already notified" mark lives in `UserDefaults`, so calling it repeatedly is safe.
enum BudgetAlertChecker {
    private static let markMonthKey = "budget_alert_month"
    private static let markLevelKey = "budget_alert_level"

    @discardableResult
    static func check(expenses: [Expense],
                      budget: Budget?,
                      notifications: NotificationServiceProtocol,
                      currencyCode: String,
                      defaults: UserDefaults = .standard,
                      now: Date = .now) async -> BudgetAlertLevel? {
        guard defaults.bool(forKey: NotificationPreferences.budgetAlertsKey), let budget else { return nil }
        let month = Period(kind: .month, containing: now)
        let spent = expenses.filter { month.contains($0.date) }.reduce(0) { $0 + $1.amount }
        guard let level = BudgetAlert.pending(spent: spent,
                                              limit: budget.monthlyLimit,
                                              last: mark(in: defaults),
                                              monthStart: month.start) else { return nil }
        // Persist before awaiting so a concurrent call (UI + intent) cannot deliver the same level twice.
        defaults.set(month.start.timeIntervalSince1970, forKey: markMonthKey)
        defaults.set(level.rawValue, forKey: markLevelKey)
        await notifications.postBudgetAlert(level, spent: spent, limit: budget.monthlyLimit, currencyCode: currencyCode)
        return level
    }

    private static func mark(in defaults: UserDefaults) -> BudgetAlertMark? {
        guard defaults.object(forKey: markMonthKey) != nil,
              let level = BudgetAlertLevel(rawValue: defaults.integer(forKey: markLevelKey)) else { return nil }
        return BudgetAlertMark(monthStart: Date(timeIntervalSince1970: defaults.double(forKey: markMonthKey)),
                               level: level)
    }
}
