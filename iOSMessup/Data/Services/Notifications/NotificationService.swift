//
//  NotificationService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation
import UserNotifications

final class NotificationService: NotificationServiceProtocol {
    private static let budgetAlertID = "budget-alert"
    private static let weeklySummaryID = "weekly-summary"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func postBudgetAlert(_ level: BudgetAlertLevel, spent: Double, limit: Double, currencyCode: String) async {
        let spentText = spent.formattedMoney(code: currencyCode)
        let limitText = limit.formattedMoney(code: currencyCode)
        let content = UNMutableNotificationContent()
        switch level {
        case .warning:
            content.title = String(localized: "Budget almost used")
            content.body = String(localized: "You have spent \(spentText) of your \(limitText) monthly budget.")
        case .over:
            content.title = String(localized: "Budget exceeded")
            content.body = String(localized: "You have spent \(spentText), over your \(limitText) monthly budget.")
        }
        content.sound = .default
        // Same identifier: an `over` alert replaces a `warning` still sitting in Notification Center.
        let request = UNNotificationRequest(identifier: Self.budgetAlertID, content: content, trigger: nil)
        try? await center.add(request)
    }

    func setWeeklySummary(enabled: Bool) async {
        guard enabled else {
            center.removePendingNotificationRequests(withIdentifiers: [Self.weeklySummaryID])
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Your week in Messup")
        content.body = String(localized: "Open the app to see how your spending compares with last week.")
        // Sunday 18:00 (`weekday` 1 is Sunday in the Gregorian calendar).
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 18, weekday: 1), repeats: true)
        let request = UNNotificationRequest(identifier: Self.weeklySummaryID, content: content, trigger: trigger)
        try? await center.add(request)
    }
}

// MARK: - Foreground presentation

/// Without a delegate iOS hides notifications while the app is open, so an alert caused by an expense added in the
/// app itself would never be seen.
final class NotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationPresenter()

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
