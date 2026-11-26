//
//  Period.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - PeriodKind

enum PeriodKind: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: Self { self }

    fileprivate var component: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}

// MARK: - Period

/// A calendar week, month or year: `start` is the first instant, `end` the first instant of the next period
/// (exclusive). Week boundaries follow the calendar's `firstWeekday`.
struct Period: Equatable, Hashable {
    let kind: PeriodKind
    let start: Date
    let end: Date
    let calendar: Calendar
    /// Number of calendar days in the period (28-31 for a month, 365/366 for a year).
    let dayCount: Int

    init(kind: PeriodKind, containing date: Date, calendar: Calendar = .current) {
        // `dateInterval(of:for:)` is non-nil for these components on every supported calendar.
        let interval = calendar.dateInterval(of: kind.component, for: date)!
        self.kind = kind
        self.start = interval.start
        self.end = interval.end
        self.calendar = calendar
        self.dayCount = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
    }

    func previous() -> Period {
        let shifted = calendar.date(byAdding: kind.component, value: -1, to: start)!
        return Period(kind: kind, containing: shifted, calendar: calendar)
    }

    func next() -> Period {
        Period(kind: kind, containing: end, calendar: calendar)
    }

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }

    /// 1-based day of the period `date` falls in, or `nil` when it is outside.
    func dayIndex(of date: Date) -> Int? {
        guard contains(date) else { return nil }
        let days = calendar.dateComponents([.day],
                                           from: calendar.startOfDay(for: start),
                                           to: calendar.startOfDay(for: date)).day!
        return days + 1
    }

    /// Start of every day of the period, resolved once, so bucketing many dates costs a binary search each
    /// instead of two `Calendar` calls.
    func dayBoundaries() -> DayBoundaries {
        let first = calendar.startOfDay(for: start)
        return DayBoundaries(starts: (0...dayCount).map { calendar.date(byAdding: .day, value: $0, to: first)! })
    }

    /// Days of the period that have started as of `now`: 0 before it begins, `dayCount` once it has ended.
    func elapsedDays(now: Date) -> Int {
        if now < start { return 0 }
        if now >= end { return dayCount }
        return dayIndex(of: now) ?? 0
    }
}

// MARK: - DayBoundaries

/// The first instant of each day of a `Period` plus the instant after its last day (`dayCount + 1` entries).
struct DayBoundaries {
    let starts: [Date]

    /// 1-based day of the period `date` falls in, or `nil` when it is outside.
    func dayIndex(of date: Date) -> Int? {
        var low = 0
        var high = starts.count
        while low < high {
            let mid = (low + high) / 2
            if starts[mid] <= date { low = mid + 1 } else { high = mid }
        }
        return (1..<starts.count).contains(low) ? low : nil
    }
}
