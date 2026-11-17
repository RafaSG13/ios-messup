//
//  SavingsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class SavingsService: SavingsServiceProtocol {
    private(set) var savingGoal: SavingGoal?
    private(set) var contributions: [Contribution] = []

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func load() async throws {
        try reloadSavingGoal()
        try reloadContributions()
    }

    func createSavingGoal(_ goal: SavingGoal) async throws {
        try replaceSavingGoal(with: goal)
    }

    func updateSavingGoal(with newValue: SavingGoal) async throws {
        try replaceSavingGoal(with: newValue)
    }

    /// Contributions are kept: they are the user's money set aside, not part of the goal.
    func deleteSavingGoal() async throws {
        let context = store.context
        try context.delete(model: SavingGoalRecord.self)
        try context.save()
        try reloadSavingGoal()
    }

    func addContribution(_ contribution: Contribution) async throws {
        let context = store.context
        context.insert(ContributionRecord(contribution))
        try context.save()
        try reloadContributions()
    }

    func updateContribution(with newValue: Contribution) async throws {
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<ContributionRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(newValue)
        try context.save()
        try reloadContributions()
    }

    func deleteContribution(_ contribution: Contribution) async throws {
        let context = store.context
        let id = contribution.id
        let records = try context.fetch(FetchDescriptor<ContributionRecord>(predicate: #Predicate { $0.id == id }))
        records.forEach { context.delete($0) }
        try context.save()
        try reloadContributions()
    }

    // MARK: - Persistence

    /// Only one saving goal exists at a time.
    private func replaceSavingGoal(with goal: SavingGoal) throws {
        let context = store.context
        try context.delete(model: SavingGoalRecord.self)
        context.insert(SavingGoalRecord(goal))
        try context.save()
        try reloadSavingGoal()
    }

    private func reloadSavingGoal() throws {
        var descriptor = FetchDescriptor<SavingGoalRecord>()
        descriptor.fetchLimit = 1
        savingGoal = try store.context.fetch(descriptor).first?.domain
    }

    private func reloadContributions() throws {
        let descriptor = FetchDescriptor<ContributionRecord>(sortBy: [SortDescriptor(\.date)])
        contributions = try store.context.fetch(descriptor).map(\.domain)
    }

    // MARK: - Derived

    func lastContributions(limit: Int) -> [Contribution] {
        Array(contributions.sorted().suffix(limit))
    }

    func totalContributed() -> Double {
        contributions.reduce(0) { $0 + $1.amount }
    }

    func progress() -> SavingGoalProgress? {
        guard let savingGoal else { return nil }
        return SavingGoalProgress(earned: totalContributed(), target: savingGoal.amount)
    }
}
