//
//  BudgetAlert.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation

// MARK: - BudgetAlertLevel

/// The budget thresholds that raise a notification: `warning` from 80 % (`BudgetProgress.warningThreshold`),
/// `over` once the limit is exceeded.
enum BudgetAlertLevel: Int, Comparable, Equatable {
    case warning = 1
    case over = 2

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - BudgetAlert

/// The last alert that was delivered, so each level fires at most once per month.
struct BudgetAlertMark: Equatable {
    let monthStart: Date
    let level: BudgetAlertLevel
}

enum BudgetAlert {
    /// The level to notify now, or `nil` when nothing new has to be said.
    ///
    /// A level is delivered once per month: crossing 80 % notifies `warning`, exceeding the limit notifies `over`
    /// (also when `warning` was skipped, e.g. one big expense). Spending that drops back never re-notifies a level
    /// already delivered in the same month; a new month re-arms both.
    static func pending(spent: Double, limit: Double, last: BudgetAlertMark?, monthStart: Date) -> BudgetAlertLevel? {
        let level: BudgetAlertLevel
        switch BudgetProgress(spent: spent, limit: limit).state {
        case .ok: return nil
        case .warning: level = .warning
        case .over: level = .over
        }
        if let last, last.monthStart == monthStart, last.level >= level { return nil }
        return level
    }
}
