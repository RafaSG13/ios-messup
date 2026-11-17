//
//  Budget.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - Budget

/// The monthly spending plan: one overall limit and optional limits per category. There is a single budget
/// that repeats every month.
struct Budget: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var monthlyLimit: Double
    var categoryLimits: [Category: Double] = [:]
}

// MARK: - Mocks

extension Budget {
    static var mock = Budget(monthlyLimit: 2000, categoryLimits: [.food: 500, .entertainment: 100])
}

// MARK: - BudgetProgress

/// How much of a limit has been spent. `warning` starts at 80 %, `over` once the limit is exceeded.
struct BudgetProgress: Equatable {
    enum State: Equatable {
        case ok
        case warning
        case over
    }

    static let warningThreshold = 0.8

    let spent: Double
    let limit: Double

    /// Spent share of the limit clamped to `0...1`; `0` when the limit is not positive.
    var fraction: Double {
        guard limit > 0 else { return 0 }
        return min(max(spent / limit, 0), 1)
    }

    /// `limit - spent`; negative once the budget is exceeded.
    var remaining: Double {
        limit - spent
    }

    var state: State {
        guard limit > 0 else { return .ok }
        if spent > limit { return .over }
        if spent >= limit * Self.warningThreshold { return .warning }
        return .ok
    }
}
