//
//  CalendarMonth.swift
//  iOSMessup
//

import Foundation

// MARK: - CalendarMonth

/// The layout of one month as a week grid: the weekday headers in the order the calendar starts its weeks, the empty
/// cells before the 1st and every day of the month.
struct CalendarMonth: Equatable {
    let period: Period
    /// Start of each day of the month, in order.
    let days: [Date]
    /// Empty cells before the 1st so it lands under its weekday.
    let leadingBlanks: Int
    /// Very short weekday names starting at the calendar's first weekday.
    let weekdaySymbols: [String]

    init(containing date: Date, calendar: Calendar = .current) {
        let period = Period(kind: .month, containing: date, calendar: calendar)
        let firstWeekday = calendar.firstWeekday
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let startWeekday = calendar.component(.weekday, from: period.start)

        self.period = period
        self.days = (0..<period.dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: period.start) }
        self.leadingBlanks = (startWeekday - firstWeekday + 7) % 7
        self.weekdaySymbols = (0..<7).map { symbols[(firstWeekday - 1 + $0) % 7] }
    }
}

// MARK: - Totals by day

extension Sequence where Element == Expense {
    /// What was spent on each calendar day, keyed by the start of the day. Days without expenses are absent.
    func totalsByDay(using calendar: Calendar = .current) -> [Date: Double] {
        reduce(into: [:]) { totals, expense in
            totals[calendar.startOfDay(for: expense.date), default: 0] += expense.amount
        }
    }
}
