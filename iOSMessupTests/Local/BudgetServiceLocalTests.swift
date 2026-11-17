//
//  BudgetServiceLocalTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import SwiftData
import Testing

struct BudgetServiceLocalTests {
    @Test func saveCreatesTheBudget() async throws {
        let service = BudgetService(store: LocalStore(storage: .inMemory))
        let budget = Budget(monthlyLimit: 1000, categoryLimits: [.food: 300])

        try await service.saveBudget(budget)

        #expect(service.budget == budget)
    }

    @Test func secondSaveReplacesAndLeavesOne() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = BudgetService(store: store)
        try await service.saveBudget(Budget(monthlyLimit: 1000))
        let second = Budget(monthlyLimit: 2000, categoryLimits: [.travel: 400])

        try await service.saveBudget(second)

        #expect(service.budget == second)
        #expect(try store.context.fetchCount(FetchDescriptor<BudgetRecord>()) == 1)
    }

    @Test func deleteRemovesTheBudget() async throws {
        let service = BudgetService(store: LocalStore(storage: .inMemory))
        try await service.saveBudget(Budget(monthlyLimit: 1000))

        try await service.deleteBudget()

        #expect(service.budget == nil)
    }

    @Test func persistsAcrossServiceInstances() async throws {
        let store = LocalStore(storage: .inMemory)
        let budget = Budget(monthlyLimit: 1500, categoryLimits: [.home: 700])
        try await BudgetService(store: store).saveBudget(budget)

        let other = BudgetService(store: store)
        try await other.load()

        #expect(other.budget == budget)
    }

    @Test func progressOfTheMonthlyLimit() async throws {
        let service = BudgetService(store: LocalStore(storage: .inMemory))
        #expect(service.progress(spent: 10) == nil)
        try await service.saveBudget(Budget(monthlyLimit: 1000))

        #expect(service.progress(spent: 850) == BudgetProgress(spent: 850, limit: 1000))
    }

    @Test func categoryProgressNeedsALimit() async throws {
        let service = BudgetService(store: LocalStore(storage: .inMemory))
        try await service.saveBudget(Budget(monthlyLimit: 1000, categoryLimits: [.food: 200]))

        #expect(service.progress(for: .food, spent: 50) == BudgetProgress(spent: 50, limit: 200))
        #expect(service.progress(for: .travel, spent: 50) == nil)
    }

    @Test func unknownCategoryKeysAreDropped() async throws {
        let store = LocalStore(storage: .inMemory)
        let record = BudgetRecord(Budget(monthlyLimit: 900, categoryLimits: [.food: 100]))
        record.categoryLimitsRaw["Removed Category"] = 42
        store.context.insert(record)
        try store.context.save()

        let service = BudgetService(store: store)
        try await service.load()

        #expect(service.budget?.categoryLimits == [.food: 100])
    }
}
