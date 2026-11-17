//
//  ExpenseInsightsTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct ExpenseInsightsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func expense(_ amount: Double, on date: Date, category: iOSMessup.Category = .food) -> Expense {
        Expense(name: "e", amount: amount, date: date, paymentMethod: .cash, category: category)
    }

    /// November 2026 (30 days) viewed on `now`.
    private func november(now: Date, expenses: [Expense]) -> PeriodSummary {
        PeriodSummary(period: Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar),
                      expenses: expenses, incomes: [], contributions: [], now: now)
    }

    @Test func noSpendingYieldsNoInsights() {
        let summary = november(now: date(2026, 11, 17), expenses: [])

        #expect(Insight.make(from: summary, monthlyLimit: 1000).isEmpty)
    }

    @Test func ordersProjectionChangeThenTopCategory() {
        let summary = november(now: date(2026, 11, 10), expenses: [
            expense(100, on: date(2026, 10, 5)),
            expense(60, on: date(2026, 11, 2), category: .travel),
            expense(40, on: date(2026, 11, 3), category: .food)
        ])

        let insights = Insight.make(from: summary, monthlyLimit: nil)

        #expect(insights.count == 3)
        #expect(insights[0] == .projection(300, budgetLimit: nil))
        #expect(insights[1] == .changeVersusPrevious(0))
        #expect(insights[2] == .topCategory(.travel, share: 0.6))
    }

    @Test func capsAtThreeInsights() {
        let summary = november(now: date(2026, 11, 10), expenses: [
            expense(100, on: date(2026, 10, 5)),
            expense(50, on: date(2026, 11, 2))
        ])

        let insights = Insight.make(from: summary, monthlyLimit: 500)

        #expect(insights.count == Insight.maximumCount)
        #expect(!insights.contains { if case .dailyAverage = $0 { true } else { false } })
    }

    @Test func projectionCarriesTheMonthlyLimit() {
        let summary = november(now: date(2026, 11, 10), expenses: [expense(100, on: date(2026, 11, 2))])

        let insights = Insight.make(from: summary, monthlyLimit: 800)

        #expect(insights.first == .projection(300, budgetLimit: 800))
    }

    @Test func nonPositiveLimitIsTreatedAsNoLimit() {
        let summary = november(now: date(2026, 11, 10), expenses: [expense(100, on: date(2026, 11, 2))])

        #expect(Insight.make(from: summary, monthlyLimit: 0).first == .projection(300, budgetLimit: nil))
    }

    @Test func finishedPeriodOmitsProjection() {
        let summary = november(now: date(2026, 12, 15), expenses: [expense(90, on: date(2026, 11, 2))])

        let insights = Insight.make(from: summary, monthlyLimit: 800)

        #expect(!insights.contains { if case .projection = $0 { true } else { false } })
        #expect(insights == [.topCategory(.food, share: 1), .dailyAverage(3)])
    }

    @Test func missingPreviousDataOmitsChange() {
        let summary = november(now: date(2026, 11, 10), expenses: [expense(100, on: date(2026, 11, 2))])

        let insights = Insight.make(from: summary, monthlyLimit: nil)

        #expect(!insights.contains { if case .changeVersusPrevious = $0 { true } else { false } })
        #expect(insights == [.projection(300, budgetLimit: nil),
                             .topCategory(.food, share: 1),
                             .dailyAverage(10)])
    }

    @Test func topCategoryShareIsFractionOfTotalSpending() {
        let summary = november(now: date(2026, 11, 30), expenses: [
            expense(25, on: date(2026, 11, 2), category: .health),
            expense(75, on: date(2026, 11, 3), category: .food)
        ])

        let insights = Insight.make(from: summary, monthlyLimit: nil)

        #expect(insights.contains(.topCategory(.food, share: 0.75)))
    }

    @Test func beforeThePeriodStartsHasNoDailyAverage() {
        let summary = november(now: date(2026, 10, 20), expenses: [expense(10, on: date(2026, 11, 2))])

        let insights = Insight.make(from: summary, monthlyLimit: nil)

        #expect(!insights.contains { if case .dailyAverage = $0 { true } else { false } })
    }
}
