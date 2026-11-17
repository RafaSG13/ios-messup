//
//  DebugSeederTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import Foundation
@testable import iOSMessup
import Testing

@MainActor
struct DebugSeederTests {

    @Test func replaceWithSampleDataDoesNotDuplicate() async throws {
        let store = LocalStore(storage: .inMemory)

        try DebugSeeder.replaceWithSampleData(in: store)
        try DebugSeeder.replaceWithSampleData(in: store)

        let expenses = ExpensesService(store: store)
        let income = IncomeService(store: store)
        try await expenses.loadExpenses()
        try await income.load()
        #expect(expenses.expenses.count == Expense.mockArray.count)
        #expect(income.deposits.count == Deposit.mockArray.count)
        #expect(income.savingGoal == SavingGoal.mock)
    }

    @Test func deleteAllDataEmptiesEverything() async throws {
        let store = LocalStore(storage: .inMemory)
        try DebugSeeder.replaceWithSampleData(in: store)

        try DebugSeeder.deleteAllData(in: store)

        let expenses = ExpensesService(store: store)
        let income = IncomeService(store: store)
        try await expenses.loadExpenses()
        try await income.load()
        #expect(expenses.expenses.isEmpty)
        #expect(income.deposits.isEmpty)
        #expect(income.savingGoal == nil)
    }
}
#endif
