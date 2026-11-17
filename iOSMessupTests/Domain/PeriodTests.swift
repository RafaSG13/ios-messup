//
//  PeriodTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct PeriodTests {
    /// Gregorian, UTC, weeks start on Monday: deterministic on any machine.
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    @Test func monthCoversWholeMonthAndEndIsExclusive() {
        let period = Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar)

        #expect(period.start == date(2026, 11, 1, hour: 0))
        #expect(period.end == date(2026, 12, 1, hour: 0))
        #expect(period.dayCount == 30)
        #expect(period.contains(date(2026, 11, 30, hour: 23)))
        #expect(period.contains(date(2026, 12, 1, hour: 0)) == false)
        #expect(period.contains(date(2026, 10, 31, hour: 23)) == false)
    }

    @Test func februaryLengthFollowsLeapYears() {
        #expect(Period(kind: .month, containing: date(2024, 2, 15), calendar: calendar).dayCount == 29)
        #expect(Period(kind: .month, containing: date(2025, 2, 15), calendar: calendar).dayCount == 28)
        #expect(Period(kind: .year, containing: date(2024, 6, 1), calendar: calendar).dayCount == 366)
        #expect(Period(kind: .year, containing: date(2025, 6, 1), calendar: calendar).dayCount == 365)
    }

    @Test func weekStartsOnTheCalendarFirstWeekday() {
        let period = Period(kind: .week, containing: date(2026, 11, 17), calendar: calendar)

        #expect(period.start == date(2026, 11, 16, hour: 0))
        #expect(period.end == date(2026, 11, 23, hour: 0))
        #expect(period.dayCount == 7)
        #expect(period.previous().start == date(2026, 11, 9, hour: 0))
    }

    @Test func previousAndNextCrossYearBoundaries() {
        let january = Period(kind: .month, containing: date(2026, 1, 20), calendar: calendar)

        #expect(january.previous().start == date(2025, 12, 1, hour: 0))
        #expect(january.previous().dayCount == 31)
        #expect(january.next().start == date(2026, 2, 1, hour: 0))
        #expect(january.next().previous() == january)
    }

    @Test func dayIndexIsOneBasedAndNilOutsideThePeriod() {
        let period = Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar)

        #expect(period.dayIndex(of: date(2026, 11, 1, hour: 0)) == 1)
        #expect(period.dayIndex(of: date(2026, 11, 30, hour: 23)) == 30)
        #expect(period.dayIndex(of: date(2026, 12, 1, hour: 0)) == nil)
    }

    @Test func elapsedDaysIsZeroBeforeAndFullAfterThePeriod() {
        let period = Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar)

        #expect(period.elapsedDays(now: date(2026, 10, 31)) == 0)
        #expect(period.elapsedDays(now: date(2026, 11, 10)) == 10)
        #expect(period.elapsedDays(now: date(2026, 12, 5)) == 30)
    }
}
