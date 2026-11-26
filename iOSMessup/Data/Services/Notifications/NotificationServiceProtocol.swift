//
//  NotificationServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation
import SwiftUI

/// Opt-in switches, written by Settings through `@AppStorage`. Both are off until the user turns them on.
enum NotificationPreferences {
    static let budgetAlertsKey = "notifications_budget_alerts"
    static let weeklySummaryKey = "notifications_weekly_summary"
}

enum NotificationError: LocalizedError {
    case denied

    var errorDescription: String? {
        String(localized: "Notifications are turned off for Messup. Enable them in the iOS Settings app.")
    }
}

protocol NotificationServiceProtocol: AnyObject {
    /// Asks for permission (the system prompt appears only the first time). `true` when notifications can be shown.
    func requestAuthorization() async -> Bool
    /// Delivers a budget alert immediately.
    func postBudgetAlert(_ level: BudgetAlertLevel, spent: Double, limit: Double, currencyCode: String) async
    /// Schedules (or cancels) the repeating weekly summary reminder.
    func setWeeklySummary(enabled: Bool) async
}

extension EnvironmentValues {
    @Entry var notificationService: NotificationServiceProtocol = defaultNotificationService
    // A `static let`: the macro's getter runs on every fallback read, so `MockNotificationService()` there would allocate a new service each time.
    private static let defaultNotificationService = MockNotificationService()
}
