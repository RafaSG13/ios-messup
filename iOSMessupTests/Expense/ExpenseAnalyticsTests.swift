//
//  ExpenseAnalyticsTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct ExpenseAnalyticsTests {
    private let reference = Date(timeIntervalSince1970: 1_700_000_000)

    private func expense(_ amount: Double, _ category: iOSMessup.Category, daysAgo: Double = 0) -> Expense {
        Expense(name: "Test",
                amount: amount,
                date: reference.addingTimeInterval(-daysAgo * 86_400),
                paymentMethod: .cash,
                category: category)
    }

    @Test func sumsAmountsPerCategory() {
        let totals = [expense(10, .food), expense(5.5, .food), expense(20, .travel)].totalsByCategory()

        #expect(totals.first { $0.category == .food }?.amount == 15.5)
        #expect(totals.first { $0.category == .travel }?.amount == 20)
        #expect(totals.count == 2)
    }

    @Test func sortsByAmountDescending() {
        let totals = [expense(5, .food), expense(50, .travel), expense(20, .health)].totalsByCategory()

        #expect(totals.map(\.category) == [.travel, .health, .food])
    }

    @Test func sinceBoundaryIsInclusive() {
        let cutoff = reference.addingTimeInterval(-10 * 86_400)
        let expenses = [expense(1, .food, daysAgo: 10),
                        expense(2, .travel, daysAgo: 10.001),
                        expense(4, .health, daysAgo: 1)]

        let totals = expenses.totalsByCategory(since: cutoff)

        #expect(Set(totals.map(\.category)) == [.food, .health])
    }

    @Test func emptyInputYieldsNoTotals() {
        #expect([Expense]().totalsByCategory().isEmpty)
    }
}
