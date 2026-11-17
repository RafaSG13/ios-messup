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
