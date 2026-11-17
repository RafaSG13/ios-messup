//
//  ExpenseInsights.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - Insight

/// One short observation about the spending of a period. The view turns each case into a sentence.
enum Insight: Equatable {
    /// The biggest category and its share of the period's spending (`0.4` = 40 %).
    case topCategory(Category, share: Double)
    /// Relative change versus the previous period (`0.1` = 10 % more).
    case changeVersusPrevious(Double)
    /// Projected total by the end of the period and the monthly limit it is compared against, if any.
    case projection(Double, budgetLimit: Double?)
    /// Spent per elapsed day.
    case dailyAverage(Double)

    static let maximumCount = 3

    /// At most `maximumCount` insights, most useful first: projection, change versus the previous period, top
    /// category, daily average. Whatever cannot be computed is omitted: nothing is reported for a period without
    /// spending, the projection needs a period in progress and the change needs spending in the previous period.
    /// `monthlyLimit` is only used to qualify the projection; pass `nil` unless the period is a month.
    static func make(from summary: PeriodSummary, monthlyLimit: Double?) -> [Insight] {
        guard summary.spent > 0 else { return [] }

        var insights: [Insight] = []
        if let projected = summary.projectedSpent {
            let limit = monthlyLimit.flatMap { $0 > 0 ? $0 : nil }
            insights.append(.projection(projected, budgetLimit: limit))
        }
        if let change = summary.changeVersusPrevious {
            insights.append(.changeVersusPrevious(change))
        }
        if let top = summary.categoryTotals.first {
            insights.append(.topCategory(top.category, share: top.amount / summary.spent))
        }
        if summary.elapsedDays > 0 {
            insights.append(.dailyAverage(summary.dailyAverage))
        }
        return Array(insights.prefix(maximumCount))
    }
}
