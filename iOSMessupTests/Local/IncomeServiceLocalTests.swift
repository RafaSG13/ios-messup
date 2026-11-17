//
//  IncomeServiceLocalTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

@MainActor
struct IncomeServiceLocalTests {

    private func makeDeposit(_ concept: String, daysAgo: Int = 0, amount: Double = 100) -> Deposit {
        Deposit(concept: concept,
                amount: amount,
                date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400)),
                foundingSource: .salary)
    }

    private func makeGoal(_ name: String, amount: Double = 1000, completion: CompletionDate = .undefined) -> SavingGoal {
        SavingGoal(name: name, completionDate: completion, amount: amount, savingCategory: .vacation)
    }

    @Test func depositCrudPersistsAcrossServiceInstances() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = IncomeService(store: store)
        var salary = makeDeposit("Salary", daysAgo: 2)
        let gift = makeDeposit("Gift", daysAgo: 1)
        let bonus = makeDeposit("Bonus", daysAgo: 0)
        try await service.createDeposit(salary)
        try await service.createDeposit(gift)
        try await service.createDeposit(bonus)

        salary.amount = 250
        try await service.updateDeposit(with: salary)
        try await service.deleteDeposit(gift)
        try await service.deleteDeposits(removeAt: [1])

        let other = IncomeService(store: store)
        try await other.load()
        #expect(other.deposits == [salary])
    }

    @Test func updateDepositWithUnknownIdIsNoOp() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        let deposit = makeDeposit("Salary")
        try await service.createDeposit(deposit)

        try await service.updateDeposit(with: makeDeposit("Ghost"))

        #expect(service.deposits == [deposit])
    }

    @Test func savingGoalIsSingleAndRoundTripsCompletionDate() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = IncomeService(store: store)

        try await service.createSavingGoal(makeGoal("First"))
        let fixed = makeGoal("Second", completion: .fixed(Date().addingTimeInterval(86_400)))
        try await service.createSavingGoal(fixed)

        let other = IncomeService(store: store)
        try await other.load()
        #expect(other.savingGoal == fixed)

        let undefined = makeGoal("Third", completion: .undefined)
        try await other.updateSavingGoal(with: undefined)
        try await service.load()
        #expect(service.savingGoal == undefined)
    }

    @Test func deleteSavingGoalClearsGoal() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        try await service.createSavingGoal(makeGoal("Goal"))

        try await service.deleteSavingGoal()

        #expect(service.savingGoal == nil)
    }

    @Test func progressIsCappedAtOne() async throws {
        let service = IncomeService(store: LocalStore(storage: .inMemory))
        try await service.createSavingGoal(makeGoal("Goal", amount: 100))
        try await service.createDeposit(makeDeposit("A", amount: 40))
        #expect(service.calculateActualProgress() == 0.4)

        try await service.createDeposit(makeDeposit("B", amount: 500))

        #expect(service.calculateActualProgress() == 1.0)
    }
}
