//
//  ExpenseAnalytics.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - CategoryTotal

/// Total spent in one category.
struct CategoryTotal: Identifiable, Equatable {
    let category: Category
    let amount: Double

    var id: Category { category }
}

extension Sequence where Element == Expense {
    /// Sums the expenses per category, biggest total first. Expenses dated before `since` are ignored
    /// (an expense dated exactly `since` is included).
    func totalsByCategory(since: Date? = nil) -> [CategoryTotal] {
        var sums: [Category: Double] = [:]
        for expense in self where since.map({ expense.date >= $0 }) ?? true {
            sums[expense.category, default: 0] += expense.amount
        }
        return sums
            .map { CategoryTotal(category: $0.key, amount: $0.value) }
            .sorted { $0.amount != $1.amount ? $0.amount > $1.amount : $0.category.rawValue < $1.category.rawValue }
    }
}

// MARK: - Top categories

extension CategoryTotal {
    /// Splits `totals` (biggest first, as `totalsByCategory` returns them) into the first `limit` categories and the
    /// sum of the rest (`0` when nothing is left over).
    static func topCategories(_ totals: [CategoryTotal], limit: Int) -> (top: [CategoryTotal], other: Double) {
        let count = max(limit, 0)
        let top = Array(totals.prefix(count))
        let other = totals.dropFirst(count).reduce(0) { $0 + $1.amount }
        return (top, other)
    }
}
