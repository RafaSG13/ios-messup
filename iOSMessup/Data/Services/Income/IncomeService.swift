//
//  IncomeService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class IncomeService: IncomeServiceProtocol {
    private(set) var deposits: [Deposit] = []
    private(set) var savingGoal: SavingGoal?

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    @MainActor
    func load() async throws {
        try reloadDeposits()
        try reloadSavingGoal()
    }

    @MainActor
    func createSavingGoal(_ goal: SavingGoal) async throws {
        try replaceSavingGoal(with: goal)
    }

    @MainActor
    func createDeposit(_ deposit: Deposit) async throws {
        let context = store.context
        context.insert(DepositRecord(deposit))
        try context.save()
        try reloadDeposits()
    }

    @MainActor
    func updateSavingGoal(with newValue: SavingGoal) async throws {
        try replaceSavingGoal(with: newValue)
    }

    @MainActor
    func updateDeposit(with newValue: Deposit) async throws {
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<DepositRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(newValue)
        try context.save()
        try reloadDeposits()
    }

    @MainActor
    func deleteSavingGoal() async throws {
        let context = store.context
        try context.delete(model: SavingGoalRecord.self)
        try context.save()
        try reloadSavingGoal()
    }

    @MainActor
    func deleteDeposits(removeAt indices: IndexSet) async throws {
        let ids = indices.compactMap { deposits.indices.contains($0) ? deposits[$0].id : nil }
        try deleteDepositRecords(withIDs: ids)
    }

    @MainActor
    func deleteDeposit(_ deposit: Deposit) async throws {
        try deleteDepositRecords(withIDs: [deposit.id])
    }

    // MARK: - Persistence

    @MainActor
    private func deleteDepositRecords(withIDs ids: [String]) throws {
        let context = store.context
        let records = try context.fetch(FetchDescriptor<DepositRecord>(predicate: #Predicate { ids.contains($0.id) }))
        records.forEach { context.delete($0) }
        try context.save()
        try reloadDeposits()
    }

    /// Only one saving goal exists at a time.
    @MainActor
    private func replaceSavingGoal(with goal: SavingGoal) throws {
        let context = store.context
        try context.delete(model: SavingGoalRecord.self)
        context.insert(SavingGoalRecord(goal))
        try context.save()
        try reloadSavingGoal()
    }

    @MainActor
    private func reloadDeposits() throws {
        let descriptor = FetchDescriptor<DepositRecord>(sortBy: [SortDescriptor(\.date)])
        deposits = try store.context.fetch(descriptor).map(\.domain)
    }

    @MainActor
    private func reloadSavingGoal() throws {
        var descriptor = FetchDescriptor<SavingGoalRecord>()
        descriptor.fetchLimit = 1
        savingGoal = try store.context.fetch(descriptor).first?.domain
    }

    // MARK: - Derived

    func lastDeposits(limit: Int) -> [Deposit] {
        Array(deposits.sorted().suffix(limit))
    }

    func calculateTotalFounded() -> Double {
        deposits.reduce(0) { $0 + $1.amount }
    }

    func calculateActualProgress() -> Double {
        guard let savingGoal, savingGoal.amount > 0 else { return 0 }
        let progress = calculateTotalFounded() / savingGoal.amount
        return min(progress, 1.0)
    }

    func filteredDeposits(on searchTerm: String) -> [Deposit] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return deposits }
        return deposits.filter { $0.concept.localizedCaseInsensitiveContains(searchTerm) }
    }
}
