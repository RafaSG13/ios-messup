//
//  CalendarMonthTests.swift
//  iOSMessupTests
//

import Foundation
import Testing
@testable import iOSMessup

struct CalendarMonthTests {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func date(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    @Test func novemberStartsOnSundayAndLeadsWithSixBlanksWhenWeeksStartOnMonday() {
        let calendar = calendar(firstWeekday: 2)
        let month = CalendarMonth(containing: date(calendar, 2026, 11, 17), calendar: calendar)

        #expect(month.days.count == 30)
        #expect(month.leadingBlanks == 6)
        #expect(month.weekdaySymbols.first == "M")
        #expect(month.weekdaySymbols.last == "S")
    }

    @Test func novemberHasNoLeadingBlanksWhenWeeksStartOnSunday() {
        let calendar = calendar(firstWeekday: 1)
        let month = CalendarMonth(containing: date(calendar, 2026, 11, 17), calendar: calendar)

        #expect(month.leadingBlanks == 0)
        #expect(month.days.first == calendar.startOfDay(for: date(calendar, 2026, 11, 1)))
        #expect(month.days.last == calendar.startOfDay(for: date(calendar, 2026, 11, 30)))
    }

    @Test func totalsByDayAddsExpensesOfTheSameDayAndSkipsEmptyDays() {
        let calendar = calendar(firstWeekday: 2)
        func expense(_ amount: Double, _ day: Int, hour: Int) -> Expense {
            Expense(name: "e", amount: amount, date: date(calendar, 2026, 11, day, hour: hour),
                    paymentMethod: .cash, category: .food)
        }
        let totals = [expense(10, 3, hour: 8), expense(5.5, 3, hour: 23), expense(7, 4, hour: 0)]
            .totalsByDay(using: calendar)

        #expect(totals.count == 2)
        #expect(totals[calendar.startOfDay(for: date(calendar, 2026, 11, 3))] == 15.5)
        #expect(totals[calendar.startOfDay(for: date(calendar, 2026, 11, 4))] == 7)
    }
}
