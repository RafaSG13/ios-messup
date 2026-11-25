//
//  IntelligencePromptsTests.swift
//  iOSMessupTests
//

import Foundation
import Testing
@testable import iOSMessup

struct IntelligencePromptsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func expense(_ name: String,
                         _ amount: Double,
                         day: Int,
                         category: iOSMessup.Category = .food) -> Expense {
        Expense(name: name, amount: amount, date: date(2026, 11, day), paymentMethod: .cash, category: category)
    }

    private var november: Period {
        Period(kind: .month, containing: date(2026, 11, 17), calendar: calendar)
    }

    // MARK: - Periods

    @Test func previousMonthStartsOnTheFirstOfLastMonth() {
        let period = IntelligencePrompts.period(kind: .month, periodsAgo: 1, now: date(2026, 1, 15), calendar: calendar)
        #expect(period.start == date(2025, 12, 1, hour: 0))
    }

    // MARK: - Expense search

    @Test func searchListsAtMostTenExpensesNewestFirst() {
        let expenses = (1...12).map { expense("Coffee \($0)", 3, day: $0) }
        let report = IntelligencePrompts.expenseSearch(expenses, query: nil, category: nil,
                                                       period: november, currencyCode: "EUR")
        let lines = report.split(separator: "\n").map(String.init)
        #expect(lines[0].hasPrefix("12 expenses"))
        #expect(lines.count == 11)
        #expect(lines[1].hasPrefix("2026-11-12"))
    }

    @Test func searchMatchesNamesIgnoringCase() {
        let expenses = [expense("Uber Eats", 20, day: 3), expense("Taxi", 15, day: 4)]
        let report = IntelligencePrompts.expenseSearch(expenses, query: "uber", category: nil,
                                                       period: november, currencyCode: "EUR")
        #expect(report.contains("Uber Eats"))
        #expect(!report.contains("Taxi"))
    }

    @Test func searchWithoutMatchesSaysSo() {
        let report = IntelligencePrompts.expenseSearch([expense("Taxi", 15, day: 4)], query: "pizza",
                                                       category: nil, period: november, currencyCode: "EUR")
        #expect(report == "No matching expenses.")
    }

    @Test func searchIgnoresExpensesOutsideThePeriodAndCategory() {
        let expenses = [expense("Rent", 900, day: 1, category: .home),
                        expense("Lunch", 12, day: 2, category: .food)]
        let report = IntelligencePrompts.expenseSearch(expenses, query: nil, category: .home,
                                                       period: november, currencyCode: "EUR")
        #expect(report.contains("Rent"))
        #expect(!report.contains("Lunch"))
    }

    // MARK: - Summary facts

    private func summary(_ expenses: [Expense]) -> PeriodSummary {
        PeriodSummary(period: november, expenses: expenses, incomes: [], contributions: [], now: date(2026, 11, 17))
    }

    @Test func summaryFactsContainFormattedSpentAndBudgetOnlyWithALimit() {
        let facts = summary([expense("Lunch", 1234.5, day: 2)])
        let withBudget = IntelligencePrompts.summaryFacts(facts, monthlyLimit: 2000, currencyCode: "EUR")
        let withoutBudget = IntelligencePrompts.summaryFacts(facts, monthlyLimit: nil, currencyCode: "EUR")

        #expect(withBudget.contains(1234.5.formattedMoney(code: "EUR")))
        #expect(withBudget.contains("Budget:"))
        #expect(!withoutBudget.contains("Budget:"))
    }

    @Test func summaryFactsListAtMostThreeCategories() {
        let categories: [iOSMessup.Category] = [.food, .home, .travel, .health, .fashion]
        let expenses = categories.enumerated().map { expense("e", Double(100 - $0.offset), day: 2 + $0.offset, category: $0.element) }
        let facts = IntelligencePrompts.summaryFacts(summary(expenses), monthlyLimit: nil, currencyCode: "EUR")

        let line = facts.split(separator: "\n").first { $0.hasPrefix("Top categories:") }
        #expect(line?.split(separator: ";").count == 3)
    }

    // MARK: - Savings

    @Test func savingsReportWithoutGoal() {
        let report = IntelligencePrompts.savingsReport(goal: nil, progress: nil, contributions: [],
                                                       includeContributions: true, currencyCode: "EUR")
        #expect(report == "No saving goal set.")
    }
}
