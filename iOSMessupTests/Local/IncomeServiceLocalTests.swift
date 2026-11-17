//
//  IncomeServiceLocalTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct IncomeServiceLocalTests {

    private func makeIncome(_ concept: String, daysAgo: Int = 0, amount: Double = 100) -> Income {
        Income(concept: concept,
               amount: amount,
               date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400)),
               source: .salary)
    }

    @Test func incomeCrudPersistsAcrossServiceInstances() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = IncomeService(store: store)
        var salary = makeIncome("Salary", daysAgo: 2)
        let gift = makeIncome("Gift", daysAgo: 1)
        try await service.createIncome(salary)
        try await service.createIncome(gift)

        salary.amount = 250
        salary.source = .freelance
        try await service.updateIncome(with: salary)
        try await service.deleteIncome(gift)

        let other = IncomeService(store: store)
        try await other.load()
        #expect(other.incomes == [salary])
    }

    @Test func updateIncomeWithUnknownIdIsNoOp() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        let income = makeIncome("Salary")
        try await service.createIncome(income)

        try await service.updateIncome(with: makeIncome("Ghost"))

        #expect(service.incomes == [income])
    }

    @Test func incomesAreSortedByDateAscending() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        let newer = makeIncome("Newer", daysAgo: 1)
        let older = makeIncome("Older", daysAgo: 5)
        try await service.createIncome(newer)
        try await service.createIncome(older)

        #expect(service.incomes == [older, newer])
    }

    @Test func filteredIncomesIgnoresTermsOfThreeCharactersOrLess() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        try await service.createIncome(makeIncome("Salary"))
        try await service.createIncome(makeIncome("Gift"))

        #expect(service.filteredIncomes(on: "gif").count == 2)
        #expect(service.filteredIncomes(on: "").count == 2)
        #expect(service.filteredIncomes(on: "sala").map(\.concept) == ["Salary"])
    }

    @Test func lastIncomesReturnsNewestOldestFirst() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        let oldest = makeIncome("A", daysAgo: 3)
        let middle = makeIncome("B", daysAgo: 2)
        let newest = makeIncome("C", daysAgo: 1)
        try await service.createIncome(newest)
        try await service.createIncome(oldest)
        try await service.createIncome(middle)

        #expect(service.lastIncomes(limit: 2) == [middle, newest])
    }
}
