//
//  BudgetAlertsModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import SwiftUI

// MARK: - BudgetAlertsModifier

/// Re-checks the budget thresholds whenever expenses or the budget change (add, edit, delete, budget form). The
/// checker ignores repeats, so it is safe that several writes fire it.
private struct BudgetAlertsModifier: ViewModifier {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.budgetService) private var budgetService
    @Environment(\.notificationService) private var notificationService
    @Environment(\.currencyCode) private var currencyCode

    func body(content: Content) -> some View {
        content
            .onChange(of: expenseService.expenses) { check() }
            .onChange(of: budgetService.budget) { check() }
    }

    private func check() {
        Task {
            await BudgetAlertChecker.check(expenses: expenseService.expenses,
                                           budget: budgetService.budget,
                                           notifications: notificationService,
                                           currencyCode: currencyCode)
        }
    }
}

extension View {
    func budgetAlerts() -> some View {
        modifier(BudgetAlertsModifier())
    }
}
