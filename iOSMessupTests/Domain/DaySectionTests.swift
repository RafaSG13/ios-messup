//
//  DaySectionTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct DaySectionTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour))!
    }

    @Test func groupsByCalendarDayNewestFirst() {
        let expenses = [
            Expense(name: "old", amount: 1, date: date(1, hour: 23), paymentMethod: .cash, category: .food),
            Expense(name: "new morning", amount: 1, date: date(3, hour: 8), paymentMethod: .cash, category: .food),
            Expense(name: "new evening", amount: 1, date: date(3, hour: 20), paymentMethod: .cash, category: .food),
            Expense(name: "middle", amount: 1, date: date(2, hour: 0), paymentMethod: .cash, category: .food)
        ]

        let sections = expenses.groupedByDay(using: calendar, date: \.date)

        #expect(sections.map(\.day) == [date(3, hour: 0), date(2, hour: 0), date(1, hour: 0)])
        #expect(sections[0].items.map(\.name) == ["new evening", "new morning"])
    }

    @Test func midnightBoundaryBelongsToTheNewDay() {
        let expenses = [
            Expense(name: "late", amount: 1, date: date(1, hour: 23), paymentMethod: .cash, category: .food),
            Expense(name: "midnight", amount: 1, date: date(2, hour: 0), paymentMethod: .cash, category: .food)
        ]

        let sections = expenses.groupedByDay(using: calendar, date: \.date)

        #expect(sections.count == 2)
        #expect(sections[0].items.map(\.name) == ["midnight"])
    }

    @Test func emptyInputGivesNoSections() {
        #expect([Expense]().groupedByDay(using: calendar, date: \.date).isEmpty)
    }
}
