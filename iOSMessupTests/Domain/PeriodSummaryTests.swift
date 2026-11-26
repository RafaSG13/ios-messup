//
//  PeriodSummaryTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct PeriodSummaryTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func expense(_ amount: Double, on date: Date, category: iOSMessup.Category = .food) -> Expense {
        Expense(name: "e", amount: amount, date: date, paymentMethod: .cash, category: category)
    }

    private func november(now: Date, expenses: [Expense] = [], incomes: [Income] = [],
                          debts: [DebtEntry] = []) -> PeriodSummary {
        PeriodSummary(period: Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar),
                      expenses: expenses, incomes: incomes, debts: debts, now: now)
    }

    @Test func sumsOnlyItemsInsideThePeriodBoundariesIncluded() {
        let summary = november(now: date(2026, 11, 17), expenses: [
            expense(10, on: date(2026, 10, 31, hour: 23)),
            expense(20, on: date(2026, 11, 1, hour: 0)),
            expense(30, on: date(2026, 11, 30, hour: 23)),
            expense(40, on: date(2026, 12, 1, hour: 0))
        ])

        #expect(summary.spent == 50)
        #expect(summary.previousSpent == 10)
    }

    @Test func balanceAddsNetDebtCashFlow() {
        let alex = "alex"
        let summary = november(
            now: date(2026, 11, 17),
            expenses: [expense(200, on: date(2026, 11, 3))],
            incomes: [Income(concept: "Salary", amount: 1000, date: date(2026, 11, 1), source: .salary)],
            debts: [DebtEntry(personID: alex, kind: .lent, amount: 100, date: date(2026, 11, 4)),
                    DebtEntry(personID: alex, kind: .receivedPayment, amount: 40, date: date(2026, 11, 8)),
                    DebtEntry(personID: alex, kind: .borrowed, amount: 50, date: date(2026, 11, 9)),
                    DebtEntry(personID: alex, kind: .lent, amount: 999, date: date(2026, 12, 1))])

        #expect(summary.debtFlow == -10)
        #expect(summary.balance == 790)
    }

    @Test func changeVersusPreviousIsRelativeAndNilWithoutHistory() {
        let withHistory = november(now: date(2026, 11, 17), expenses: [
            expense(100, on: date(2026, 10, 5)),
            expense(150, on: date(2026, 11, 5))
        ])
        let withoutHistory = november(now: date(2026, 11, 17), expenses: [expense(150, on: date(2026, 11, 5))])

        #expect(withHistory.changeVersusPrevious == 0.5)
        #expect(withoutHistory.changeVersusPrevious == nil)
    }

    @Test func cumulativeSeriesStopsTodayInAnOngoingPeriod() {
        let summary = november(now: date(2026, 11, 3), expenses: [
            expense(10, on: date(2026, 11, 1)),
            expense(5, on: date(2026, 11, 3, hour: 8)),
            expense(99, on: date(2026, 11, 20))
        ])

        #expect(summary.cumulativeSpend.map(\.day) == [1, 2, 3])
        #expect(summary.cumulativeSpend.map(\.amount) == [10, 10, 15])
    }

    @Test func cumulativeSeriesOfAFinishedPeriodEndsAtTheTotal() {
        let summary = november(now: date(2026, 12, 20), expenses: [
            expense(10, on: date(2026, 11, 1)),
            expense(5, on: date(2026, 11, 30))
        ])

        #expect(summary.cumulativeSpend.count == 30)
        #expect(summary.cumulativeSpend.last?.amount == summary.spent)
        #expect(summary.cumulativeSpend.map(\.amount) == summary.cumulativeSpend.map(\.amount).sorted())
    }

    @Test func previousSeriesCoversTheWholePreviousPeriod() {
        let summary = november(now: date(2026, 11, 17), expenses: [expense(70, on: date(2026, 10, 31))])

        #expect(summary.previousCumulativeSpend.count == 31)
        #expect(summary.previousCumulativeSpend.last?.amount == 70)
        #expect(summary.previousCumulativeSpend.first?.amount == 0)
    }

    @Test func projectionExtrapolatesLinearlyOnlyWhileInProgress() {
        let inProgress = november(now: date(2026, 11, 10), expenses: [expense(100, on: date(2026, 11, 4))])
        let finished = november(now: date(2026, 12, 3), expenses: [expense(100, on: date(2026, 11, 4))])
        let notStarted = november(now: date(2026, 10, 20), expenses: [expense(100, on: date(2026, 11, 4))])

        #expect(inProgress.dailyAverage == 10)
        #expect(inProgress.projectedSpent == 300)
        #expect(finished.projectedSpent == nil)
        #expect(notStarted.projectedSpent == nil)
        #expect(notStarted.dailyAverage == 0)
    }

    @Test func partialPeriodIsComparedWithTheSameDaysOfThePreviousOne() {
        let partial = november(now: date(2026, 11, 17), expenses: [
            expense(100, on: date(2026, 10, 5)),
            expense(900, on: date(2026, 10, 25)),
            expense(150, on: date(2026, 11, 5))
        ])
        let finished = november(now: date(2026, 12, 20), expenses: [
            expense(100, on: date(2026, 10, 5)),
            expense(900, on: date(2026, 10, 25)),
            expense(1000, on: date(2026, 11, 5))
        ])

        #expect(partial.previousSpentToDate == 100)
        #expect(partial.changeVersusPrevious == 0.5)
        #expect(finished.previousSpentToDate == 1000)
        #expect(finished.changeVersusPrevious == 0)
    }

    @Test func emptyPeriodIsAllZeros() {
        let summary = november(now: date(2026, 11, 17))

        #expect(summary.spent == 0)
        #expect(summary.balance == 0)
        #expect(summary.categoryTotals.isEmpty)
        #expect(summary.cumulativeSpend.count == 17)
        #expect(summary.cumulativeSpend.allSatisfy { $0.amount == 0 })
    }

    @Test func categoryTotalsAreBiggestFirstAndLimitedToThePeriod() {
        let summary = november(now: date(2026, 11, 17), expenses: [
            expense(10, on: date(2026, 11, 2), category: .food),
            expense(80, on: date(2026, 11, 3), category: .travel),
            expense(500, on: date(2026, 10, 3), category: .home)
        ])

        #expect(summary.categoryTotals.map(\.category) == [.travel, .food])
    }

    @Test func spendBarsHaveOneEntryPerDayAndMarkTheDayInProgress() {
        let summary = november(now: date(2026, 11, 17), expenses: [
            expense(10, on: date(2026, 11, 1)),
            expense(5, on: date(2026, 11, 1, hour: 20)),
            expense(7, on: date(2026, 11, 20))
        ])

        #expect(summary.spendBars.count == 30)
        #expect(summary.spendBars[0].amount == 15)
        #expect(summary.spendBars[19].amount == 7)
        #expect(summary.spendBars.map(\.amount).reduce(0, +) == summary.spent)
        #expect(summary.currentBar == 17)
    }

    @Test func yearBarsGroupByMonthAndEndedPeriodsHaveNoCurrentBar() {
        let year = Period(kind: .year, containing: date(2025, 6, 1), calendar: calendar)
        let summary = PeriodSummary(period: year,
                                    expenses: [expense(10, on: date(2025, 1, 5)),
                                               expense(20, on: date(2025, 1, 28)),
                                               expense(3, on: date(2025, 12, 31))],
                                    incomes: [], debts: [], now: date(2026, 11, 17))

        #expect(summary.spendBars.count == 12)
        #expect(summary.spendBars[0].amount == 30)
        #expect(summary.spendBars[11].amount == 3)
        #expect(summary.currentBar == nil)
    }
}
