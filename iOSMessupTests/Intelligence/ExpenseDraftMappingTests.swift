//
//  ExpenseDraftMappingTests.swift
//  iOSMessupTests
//

import Foundation
import Testing
@testable import iOSMessup

struct ExpenseDraftMappingTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private var now: Date { date(2026, 11, 25, hour: 12) }

    private func generated(name: String = "Coffee",
                           amount: Double? = 3.5,
                           date: String? = nil,
                           daysAgo: Int? = nil) -> GeneratedExpense {
        GeneratedExpense(name: name, amount: amount, date: date, daysAgo: daysAgo, paymentMethod: nil, category: nil)
    }

    @Test func explicitDateWinsOverRelativeDays() {
        let draft = ExpenseDraft(generated(date: "2026-11-20", daysAgo: 1), now: now, calendar: calendar)
        #expect(draft.date == date(2026, 11, 20))
    }

    @Test func unreadableDateFallsBackToRelativeDays() {
        let draft = ExpenseDraft(generated(date: "20/11", daysAgo: 1), now: now, calendar: calendar)
        #expect(draft.date == date(2026, 11, 24, hour: 12))
    }

    @Test func noDateInformationLeavesDateEmpty() {
        let draft = ExpenseDraft(generated(), now: now, calendar: calendar)
        #expect(draft.date == nil)
    }

    @Test func blankNameBecomesNil() {
        let draft = ExpenseDraft(generated(name: "  "), now: now, calendar: calendar)
        #expect(draft.name == nil)
    }

    @Test func zeroAmountBecomesNil() {
        let draft = ExpenseDraft(generated(amount: 0), now: now, calendar: calendar)
        #expect(draft.amount == nil)
    }

    @Test func categoryMappingCoversEveryCategory() {
        let mapped = Set(GeneratedCategory.allCases.map { iOSMessup.Category($0) })
        #expect(mapped.count == iOSMessup.Category.allCases.count)
    }

    @Test func paymentMethodMappingCoversEveryMethod() {
        let mapped = Set(GeneratedPaymentMethod.allCases.map { PaymentMethod($0) })
        #expect(mapped.count == PaymentMethod.allCases.count)
    }
}
