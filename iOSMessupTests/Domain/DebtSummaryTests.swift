//
//  DebtSummaryTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct DebtSummaryTests {
    private let day = Date(timeIntervalSince1970: 1_700_000_000)

    private func entry(_ personID: String, _ kind: DebtEntryKind, _ amount: Double, daysAfter: Int = 0) -> DebtEntry {
        DebtEntry(personID: personID, kind: kind, amount: amount, date: day.addingTimeInterval(Double(daysAfter) * 86_400))
    }

    @Test func eachKindMovesTheBalanceInItsDirection() {
        #expect(DebtSummary.balance(of: "a", in: [entry("a", .lent, 100)]) == 100)
        #expect(DebtSummary.balance(of: "a", in: [entry("a", .borrowed, 100)]) == -100)
        #expect(DebtSummary.balance(of: "a", in: [entry("a", .lent, 100), entry("a", .receivedPayment, 40)]) == 60)
        #expect(DebtSummary.balance(of: "a", in: [entry("a", .borrowed, 120), entry("a", .madePayment, 70)]) == -50)
    }

    @Test func cashFlowIsTheOppositeOfTheBalanceChange() {
        #expect(entry("a", .lent, 100).cashFlow == -100)
        #expect(entry("a", .borrowed, 100).cashFlow == 100)
        #expect(entry("a", .receivedPayment, 40).cashFlow == 40)
        #expect(entry("a", .madePayment, 70).cashFlow == -70)
    }

    @Test func overpayingFlipsWhoOwesWhom() {
        let alex = Person(id: "a", name: "Alex")
        let summary = DebtSummary(people: [alex], entries: [entry("a", .lent, 50), entry("a", .receivedPayment, 80)])

        #expect(summary.balances[0].balance == -30)
        #expect(summary.balances[0].state == .iOwe)
    }

    @Test func tinyBalancesCountAsSettled() {
        let alex = Person(id: "a", name: "Alex")
        let summary = DebtSummary(people: [alex], entries: [entry("a", .lent, 0.1 + 0.2), entry("a", .receivedPayment, 0.3)])

        #expect(summary.balances[0].state == .settled)
        #expect(summary.owedToMe == 0)
        #expect(summary.iOwe == 0)
    }

    @Test func totalsOfTheMockData() {
        let summary = DebtSummary(people: Person.mockArray, entries: DebtEntry.mockArray)

        #expect(summary.owedToMe == 45)
        #expect(summary.iOwe == 50)
        #expect(summary.net == -5)
    }

    @Test func pendingBalancesComeFirstByAmountThenSettledByName() {
        let people = [Person(id: "z", name: "Zoe"), Person(id: "b", name: "Bea"),
                      Person(id: "a", name: "Abe"), Person(id: "c", name: "Cy")]
        let summary = DebtSummary(people: people, entries: [
            entry("z", .lent, 10), entry("b", .borrowed, 30), entry("a", .lent, 5), entry("a", .receivedPayment, 5)
        ])

        #expect(summary.balances.map(\.person.name) == ["Bea", "Zoe", "Abe", "Cy"])
    }

    @Test func lastActivityIsTheLatestEntryDate() {
        let alex = Person(id: "a", name: "Alex")
        let summary = DebtSummary(people: [alex, Person(id: "b", name: "Bea")],
                                  entries: [entry("a", .lent, 5, daysAfter: 3), entry("a", .lent, 5, daysAfter: 1)])

        #expect(summary.balances.first { $0.id == "a" }?.lastActivity == day.addingTimeInterval(3 * 86_400))
        #expect(summary.balances.first { $0.id == "b" }?.lastActivity == nil)
    }

    @Test func entriesOfUnknownPeopleAreIgnored() {
        let summary = DebtSummary(people: [Person(id: "a", name: "Alex")], entries: [entry("ghost", .lent, 500)])

        #expect(summary.owedToMe == 0)
        #expect(summary.balances.count == 1)
    }
}
