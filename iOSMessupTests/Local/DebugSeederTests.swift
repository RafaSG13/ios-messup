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

struct DebugSeederTests {
    private func makeDefaults(_ values: [String: Any] = [:]) -> UserDefaults {
        let name = "DebugSeederTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        values.forEach { defaults.set($1, forKey: $0) }
        return defaults
    }

    @Test func replaceWithSampleDataDoesNotDuplicate() async throws {
        let store = LocalStore(storage: .inMemory)
        let now = Date.now

        try DebugSeeder.replaceWithSampleData(in: store, now: now)
        try DebugSeeder.replaceWithSampleData(in: store, now: now)

        let expected = SampleDataGenerator.make(now: now)
        let expenses = ExpensesService(store: store)
        let income = IncomeService(store: store)
        try await expenses.loadExpenses()
        try await income.load()
        #expect(expenses.expenses.count == expected.expenses.count)
        #expect(income.deposits.count == expected.deposits.count)
        #expect(income.savingGoal?.name == expected.goal.name)
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

    @Test func seedOnLaunchSeedsAnEmptyStoreByDefault() throws {
        let store = LocalStore(storage: .inMemory)

        try DebugSeeder.seedOnLaunch(in: store, defaults: makeDefaults())

        #expect(try DebugSeeder.isEmpty(store) == false)
    }

    @Test func seedOnLaunchKeepsUserDataInANonEmptyStore() async throws {
        let store = LocalStore(storage: .inMemory)
        let expenses = ExpensesService(store: store)
        try await expenses.addExpense(Expense.mock)

        try DebugSeeder.seedOnLaunch(in: store, defaults: makeDefaults())

        try await expenses.loadExpenses()
        #expect(expenses.expenses.map(\.id) == [Expense.mock.id])
    }

    @Test func seedOnLaunchHonoursAutoSeedOff() throws {
        let store = LocalStore(storage: .inMemory)

        try DebugSeeder.seedOnLaunch(in: store, defaults: makeDefaults([DebugSeeder.autoSeedKey: false]))

        #expect(try DebugSeeder.isEmpty(store))
    }

    @Test func forcedSeedReplacesExistingData() async throws {
        let store = LocalStore(storage: .inMemory)
        let expenses = ExpensesService(store: store)
        try await expenses.addExpense(Expense.mock)

        try DebugSeeder.seedOnLaunch(in: store, defaults: makeDefaults([DebugSeeder.forceSeedKey: true]))

        try await expenses.loadExpenses()
        #expect(expenses.expenses.contains { $0.id == Expense.mock.id } == false)
        #expect(expenses.expenses.count > 1)
    }
}
#endif
