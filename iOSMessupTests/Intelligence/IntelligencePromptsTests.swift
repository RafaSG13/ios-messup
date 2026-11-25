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
        #expect(lines[1].hasPrefix("#\(IntelligencePrompts.ref(for: expenses[11].id)) · 2026-11-12"))
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
        PeriodSummary(period: november, expenses: expenses, incomes: [], debts: [], now: date(2026, 11, 17))
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

    // MARK: - Debts

    private var people: [Person] {
        [Person(id: "p-alex", name: "Alex Rivera"), Person(id: "p-sam", name: "Sam Carter"),
         Person(id: "p-jordan", name: "Jordan Lee")]
    }

    private var entries: [DebtEntry] {
        [DebtEntry(id: "AAAAAAAA-1", personID: "p-alex", kind: .lent, amount: 60, date: date(2026, 11, 1), note: "Dinner"),
         DebtEntry(id: "BBBBBBBB-2", personID: "p-alex", kind: .receivedPayment, amount: 40, date: date(2026, 11, 5)),
         DebtEntry(id: "CCCCCCCC-3", personID: "p-sam", kind: .borrowed, amount: 120, date: date(2026, 11, 2)),
         DebtEntry(id: "DDDDDDDD-4", personID: "p-sam", kind: .madePayment, amount: 70, date: date(2026, 11, 3))]
    }

    @Test func debtsReportWithoutPeopleSaysSo() {
        let report = IntelligencePrompts.debtsReport(people: [], entries: [], personName: nil, currencyCode: "EUR")
        #expect(report == "No people registered.")
    }

    @Test func debtsReportForEveryoneListsBalancesAndTotals() {
        let report = IntelligencePrompts.debtsReport(people: people, entries: entries, personName: nil, currencyCode: "EUR")
        #expect(report.contains("Alex Rivera: owes you \(20.0.formattedMoney(code: "EUR"))"))
        #expect(report.contains("Sam Carter: you owe \(50.0.formattedMoney(code: "EUR"))"))
        #expect(report.contains("Jordan Lee: settled"))
        #expect(report.contains("Total owed to you: \(20.0.formattedMoney(code: "EUR"))"))
        #expect(report.contains("Total you owe: \(50.0.formattedMoney(code: "EUR"))"))
    }

    @Test func debtsReportForOnePersonListsHistoryNewestFirstWithRefs() {
        let report = IntelligencePrompts.debtsReport(people: people, entries: entries, personName: "alex",
                                                     currencyCode: "EUR", calendar: calendar)
        let lines = report.split(separator: "\n").map(String.init)
        #expect(lines[0] == "Alex Rivera owes you \(20.0.formattedMoney(code: "EUR"))")
        #expect(lines[1].hasPrefix("#bbbbbbbb · 2026-11-05 · receivedPayment"))
        #expect(lines[2].hasPrefix("#aaaaaaaa · 2026-11-01 · lent"))
        #expect(!report.contains("Sam"))
    }

    @Test func debtsReportWithUnknownNameSaysSo() {
        let report = IntelligencePrompts.debtsReport(people: people, entries: entries, personName: "Zed", currencyCode: "EUR")
        #expect(report == "No person matches that name.")
    }

    // MARK: - References

    @Test func refIsTheFirstEightCharactersLowercased() {
        #expect(IntelligencePrompts.ref(for: "AB12CD34-EF56-7890") == "ab12cd34")
        #expect(IntelligencePrompts.ref(for: "abc") == "abc")
    }

    @Test func resolveAcceptsHashAnyCaseAndPrefixes() {
        let items = [expense("A", 1, day: 1), expense("B", 1, day: 2)]
        let first = items[0]
        let ref = IntelligencePrompts.ref(for: first.id)

        for candidate in [ref, "#" + ref, ref.uppercased(), " #\(ref) ", String(ref.prefix(4))] {
            guard case .found(let found) = IntelligencePrompts.resolve(ref: candidate, in: items) else {
                Issue.record("\(candidate) did not resolve")
                continue
            }
            #expect(found.id == first.id)
        }
    }

    @Test func resolveRejectsShortUnknownAndAmbiguousReferences() {
        let items = [Person(id: "abcd1111", name: "A"), Person(id: "abcd2222", name: "B")]

        guard case .notFound = IntelligencePrompts.resolve(ref: "ab", in: items) else { Issue.record("short"); return }
        guard case .notFound = IntelligencePrompts.resolve(ref: "zzzz", in: items) else { Issue.record("unknown"); return }
        guard case .ambiguous = IntelligencePrompts.resolve(ref: "abcd", in: items) else { Issue.record("ambiguous"); return }
        guard case .found(let found) = IntelligencePrompts.resolve(ref: "abcd2", in: items) else { Issue.record("found"); return }
        #expect(found.name == "B")
    }

    // MARK: - Income search

    @Test func incomeSearchListsMatchesWithRefs() {
        let pay = Income(concept: "Salary", amount: 2000, date: date(2026, 11, 1), source: .salary)
        let gift = Income(concept: "Birthday gift", amount: 50, date: date(2026, 11, 3), source: .gifts)
        let old = Income(concept: "Old", amount: 9, date: date(2026, 10, 1), source: .other)

        let all = IntelligencePrompts.incomeSearch([pay, gift, old], query: nil, period: november, currencyCode: "EUR")
        let filtered = IntelligencePrompts.incomeSearch([pay, gift], query: "gift", period: november, currencyCode: "EUR")

        #expect(all.contains("#\(IntelligencePrompts.ref(for: pay.id)) · 2026-11-01 · Salary"))
        #expect(!all.contains("Old"))
        #expect(filtered.contains("Birthday gift"))
        #expect(!filtered.contains("Salary"))
        #expect(IntelligencePrompts.incomeSearch([], query: nil, period: november, currencyCode: "EUR") == "No matching income.")
    }
}
