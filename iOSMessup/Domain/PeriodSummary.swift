//
//  PeriodSummary.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - CumulativePoint

/// Cumulative spending at the end of a day of a period.
struct CumulativePoint: Identifiable, Equatable {
    /// 1-based day of the period.
    let day: Int
    let amount: Double

    var id: Int { day }
}

// MARK: - PeriodSummary

/// Everything the money screens show for one period, computed from plain arrays so it is easy to test.
/// Balance follows the app rule: income − expenses − contributions.
struct PeriodSummary: Equatable {
    let period: Period
    let spent: Double
    /// Total of the whole previous period.
    let previousSpent: Double
    /// What the previous period had spent by the same day (`elapsedDays`), the fair comparison while the current
    /// period is still in progress.
    let previousSpentToDate: Double
    let income: Double
    let contributed: Double
    /// Biggest category first.
    let categoryTotals: [CategoryTotal]
    /// One point per elapsed day (empty before the period starts, complete once it has ended).
    let cumulativeSpend: [CumulativePoint]
    /// One point per day of the previous period.
    let previousCumulativeSpend: [CumulativePoint]
    /// Days that have started as of `now` (see `Period.elapsedDays`).
    let elapsedDays: Int

    init(period: Period,
         expenses: [Expense],
         incomes: [Income],
         contributions: [Contribution],
         now: Date = .now) {
        let previousPeriod = period.previous()
        let inPeriod = expenses.filter { period.contains($0.date) }
        let inPrevious = expenses.filter { previousPeriod.contains($0.date) }

        self.period = period
        self.spent = inPeriod.reduce(0) { $0 + $1.amount }
        self.previousSpent = inPrevious.reduce(0) { $0 + $1.amount }
        self.income = incomes.filter { period.contains($0.date) }.reduce(0) { $0 + $1.amount }
        self.contributed = contributions.filter { period.contains($0.date) }.reduce(0) { $0 + $1.amount }
        self.categoryTotals = inPeriod.totalsByCategory()
        self.elapsedDays = period.elapsedDays(now: now)
        self.cumulativeSpend = Self.buildCumulative(of: inPeriod, in: period, throughDay: elapsedDays)
        self.previousCumulativeSpend = Self.buildCumulative(of: inPrevious,
                                                            in: previousPeriod,
                                                            throughDay: previousPeriod.dayCount)
        let comparableDay = min(elapsedDays, previousPeriod.dayCount)
        self.previousSpentToDate = comparableDay > 0 ? previousCumulativeSpend[comparableDay - 1].amount : 0
    }

    /// What is left to spend: income − expenses − contributions.
    var balance: Double {
        income - spent - contributed
    }

    /// Spent per elapsed day; 0 before the period starts.
    var dailyAverage: Double {
        elapsedDays > 0 ? spent / Double(elapsedDays) : 0
    }

    /// Linear projection of the total spend by the end of the period. `nil` unless the period is in progress.
    var projectedSpent: Double? {
        guard elapsedDays > 0, elapsedDays < period.dayCount else { return nil }
        return dailyAverage * Double(period.dayCount)
    }

    /// Relative change versus the previous period at the same point in time (`0.1` = 10 % more); a partial month is
    /// compared with the first days of the previous month, not with its total. `nil` when there is nothing to compare.
    var changeVersusPrevious: Double? {
        guard previousSpentToDate > 0 else { return nil }
        return (spent - previousSpentToDate) / previousSpentToDate
    }

    private static func buildCumulative(of expenses: [Expense],
                                        in period: Period,
                                        throughDay lastDay: Int) -> [CumulativePoint] {
        guard lastDay > 0 else { return [] }
        var perDay = [Double](repeating: 0, count: period.dayCount)
        for expense in expenses {
            if let day = period.dayIndex(of: expense.date) {
                perDay[day - 1] += expense.amount
            }
        }
        var running = 0.0
        return (1...lastDay).map { day in
            running += perDay[day - 1]
            return CumulativePoint(day: day, amount: running)
        }
    }
}
