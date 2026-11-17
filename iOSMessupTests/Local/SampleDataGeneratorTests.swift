//
//  SampleDataGeneratorTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import Foundation
@testable import iOSMessup
import Testing

struct SampleDataGeneratorTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    /// 17 Nov 2026, 12:00 UTC.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 17, hour: 12))!
    }

    @Test func sameSeedGivesSameContent() {
        let first = SampleDataGenerator.make(now: now, calendar: calendar, seed: 7)
        let second = SampleDataGenerator.make(now: now, calendar: calendar, seed: 7)

        #expect(first.expenses.map(\.name) == second.expenses.map(\.name))
        #expect(first.expenses.map(\.amount) == second.expenses.map(\.amount))
        #expect(first.expenses.map(\.date) == second.expenses.map(\.date))
        #expect(first.deposits.map(\.amount) == second.deposits.map(\.amount))
    }

    @Test func differentSeedsGiveDifferentSpending() {
        let first = SampleDataGenerator.make(now: now, calendar: calendar, seed: 1)
        let second = SampleDataGenerator.make(now: now, calendar: calendar, seed: 2)

        #expect(first.expenses.map(\.amount) != second.expenses.map(\.amount))
    }

    @Test func nothingIsGeneratedInTheFuture() {
        let sample = SampleDataGenerator.make(now: now, calendar: calendar)

        #expect(sample.expenses.allSatisfy { $0.date <= now })
        #expect(sample.deposits.allSatisfy { $0.date <= now })
    }

    @Test func coversTheRequestedMonthsWithASalaryEach() {
        let sample = SampleDataGenerator.make(now: now, calendar: calendar, months: 4)

        let salaryMonths = sample.deposits
            .filter { $0.foundingSource == .salary }
            .map { calendar.component(.month, from: $0.date) }
        #expect(salaryMonths.sorted() == [8, 9, 10, 11])
        #expect(sample.expenses.allSatisfy { $0.amount > 0 })
    }

    @Test func spreadsSpendingAcrossManyCategories() {
        let sample = SampleDataGenerator.make(now: now, calendar: calendar)

        #expect(Set(sample.expenses.map(\.category)).count >= 6)
    }

    @Test func currentMonthStopsAtNow() {
        let earlyInMonth = calendar.date(from: DateComponents(year: 2026, month: 11, day: 2, hour: 8))!

        let sample = SampleDataGenerator.make(now: earlyInMonth, calendar: calendar)

        #expect(sample.expenses.allSatisfy { $0.date <= earlyInMonth })
    }
}
#endif
