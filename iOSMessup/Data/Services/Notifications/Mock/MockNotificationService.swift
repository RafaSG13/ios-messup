//
//  MockNotificationService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation

/// Records what would have been delivered; used by previews, the `mock` environment and tests.
final class MockNotificationService: NotificationServiceProtocol {
    struct PostedAlert: Equatable {
        let level: BudgetAlertLevel
        let spent: Double
        let limit: Double
    }

    private(set) var postedAlerts: [PostedAlert] = []
    private(set) var weeklySummaryEnabled = false
    var isAuthorized: Bool

    init(isAuthorized: Bool = true) {
        self.isAuthorized = isAuthorized
    }

    func requestAuthorization() async -> Bool {
        isAuthorized
    }

    func postBudgetAlert(_ level: BudgetAlertLevel, spent: Double, limit: Double, currencyCode: String) async {
        postedAlerts.append(PostedAlert(level: level, spent: spent, limit: limit))
    }

    func setWeeklySummary(enabled: Bool) async {
        weeklySummaryEnabled = enabled
    }
}
