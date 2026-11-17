//
//  SavingsServiceLocalTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct SavingsServiceLocalTests {

    private func makeGoal(_ name: String, amount: Double = 1000, completion: CompletionDate = .undefined) -> SavingGoal {
        SavingGoal(name: name, completionDate: completion, amount: amount, savingCategory: .vacation)
    }

    private func makeContribution(_ note: String, daysAgo: Int = 0, amount: Double = 100) -> Contribution {
        Contribution(amount: amount,
                     date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400)),
                     note: note)
    }

    @Test func savingGoalIsSingleAndRoundTripsCompletionDate() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = SavingsService(store: store)

        try await service.createSavingGoal(makeGoal("First"))
        let fixed = makeGoal("Second", completion: .fixed(Date().addingTimeInterval(86_400)))
        try await service.createSavingGoal(fixed)

        let other = SavingsService(store: store)
        try await other.load()
        #expect(other.savingGoal == fixed)

        let undefined = makeGoal("Third", completion: .undefined)
        try await other.updateSavingGoal(with: undefined)
        try await service.load()
        #expect(service.savingGoal == undefined)
    }

    @Test func deleteSavingGoalKeepsContributions() async throws {
        let service = SavingsService(store: LocalStore(storage: .inMemory))
        let contribution = makeContribution("Saved")
        try await service.createSavingGoal(makeGoal("Goal"))
        try await service.addContribution(contribution)

        try await service.deleteSavingGoal()

        #expect(service.savingGoal == nil)
        #expect(service.contributions == [contribution])
        #expect(service.progress() == nil)
    }

    @Test func contributionCrudPersistsAcrossServiceInstances() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = SavingsService(store: store)
        var first = makeContribution("First", daysAgo: 2)
        let second = makeContribution("Second", daysAgo: 1)
        try await service.addContribution(first)
        try await service.addContribution(second)

        first.amount = 250
        first.note = "Edited"
        try await service.updateContribution(with: first)
        try await service.deleteContribution(second)

        let other = SavingsService(store: store)
        try await other.load()
        #expect(other.contributions == [first])
    }

    @Test func updateContributionWithUnknownIdIsNoOp() async throws {
        let service = SavingsService(store: LocalStore(storage: .inMemory))
        let contribution = makeContribution("Saved")
        try await service.addContribution(contribution)

        try await service.updateContribution(with: makeContribution("Ghost"))

        #expect(service.contributions == [contribution])
    }

    @Test func totalAndLastContributions() async throws {
        let service = SavingsService(store: LocalStore(storage: .inMemory))
        let oldest = makeContribution("A", daysAgo: 3, amount: 10)
        let middle = makeContribution("B", daysAgo: 2, amount: 20)
        let newest = makeContribution("C", daysAgo: 1, amount: 30)
        try await service.addContribution(newest)
        try await service.addContribution(oldest)
        try await service.addContribution(middle)

        #expect(service.totalContributed() == 60)
        #expect(service.lastContributions(limit: 2) == [middle, newest])
    }

    @Test func progressIsNilWithoutGoal() async throws {
        let service = SavingsService(store: LocalStore(storage: .inMemory))
        try await service.addContribution(makeContribution("Saved"))

        #expect(service.progress() == nil)
    }

    @Test func progressSumsContributionsAndClamps() async throws {
        let service = SavingsService(store: LocalStore(storage: .inMemory))
        try await service.createSavingGoal(makeGoal("Goal", amount: 100))
        try await service.addContribution(makeContribution("A", amount: 40))
        #expect(service.progress() == SavingGoalProgress(earned: 40, target: 100))
        #expect(service.progress()?.fraction == 0.4)
        #expect(service.progress()?.remaining == 60)

        try await service.addContribution(makeContribution("B", amount: 500))

        #expect(service.progress()?.fraction == 1)
        #expect(service.progress()?.remaining == 0)
    }

    @Test func progressIgnoresIncomes() async throws {
        let store = LocalStore(storage: .inMemory)
        let savings = SavingsService(store: store)
        let income = IncomeService(store: store)
        try await savings.createSavingGoal(makeGoal("Goal", amount: 100))
        try await income.createIncome(Income(concept: "Salary", amount: 5000, date: .now, source: .salary))

        #expect(savings.progress()?.earned == 0)
    }
}
