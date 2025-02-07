//
//  SavingViewModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation
import Observation

@Observable class SavingViewModel: SavingViewModelProtocol {

    private(set) var deposits: [Deposit] = []
    private(set) var savingGoal: SavingGoal?
    let dataSource: SavingsDataSourceProtocol
    
    init(dataSource: SavingsDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func load() async throws {
        async let goal = dataSource.readGoal()
        async let deposits = try dataSource.readAllDeposits()
        self.savingGoal = try await goal
        self.deposits = try await deposits
    }

    func  createSavingGoal(_ goal: SavingGoal) async throws {
        self.savingGoal = goal
        try? await dataSource.create(goal)
    }

    func createDeposit(_ deposit: Deposit) async throws {
        deposits.append(deposit)
        try? await dataSource.create(deposit)
    }

    func updateSavingGoal(with newValue: SavingGoal) async throws {
        self.savingGoal = newValue
        try? await dataSource.update(newValue)
    }

    func updateDeposit(with newValue: Deposit) async throws {
        deposits = deposits.map { $0.id == newValue.id ? newValue : $0 }
        try? await dataSource.update(newValue)
    }

    func deleteSavingGoal() async throws{
        guard let savingGoal else { return }
        try? await dataSource.delete(savingGoal)
        self.savingGoal = nil
    }

    func deleteDeposits(removeAt indices: IndexSet) async throws {
        let depositsToDelete = indices.compactMap { deposits.indices.contains($0) ? deposits[$0] : nil }
        deposits.remove(atOffsets: indices)
        try? await dataSource.deleteAll(depositsToDelete)
    }

    func deleteDeposit(_ deposit: Deposit) async throws {
        deposits.removeAll { $0.id == deposit.id }
        try? await dataSource.delete(deposit)
    }

    func lastDeposits(limit: Int) -> [Deposit] {
        return deposits.sorted().suffix(limit)
    }

    func calculateTotalFounded() -> Double {
        return deposits.reduce(0) { $0 + $1.amount }
    }

    func calculateActualProgress() -> Double {
        guard let savingGoal = savingGoal else { return 0 }
        let result = calculateTotalFounded() / savingGoal.amount
        return result >= 1 ? 1 : result
    }

    func filteredDeposits(on searchTerm: String) -> [Deposit] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return deposits }
        return deposits.filter { $0.concept.lowercased().contains(searchTerm.lowercased()) }
    }
}
