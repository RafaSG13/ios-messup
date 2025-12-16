//
//  SavingViewModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation
import Observation
import SwiftUI

extension EnvironmentValues {
    @Entry() var incomeRepository: IncomeRepository = IncomeRepository(dataSource: IncomeDataSourceMock())
}


@Observable class IncomeRepository {

    var deposits: [Deposit] {
        dataSource.deposits
    }

    var savingGoal: SavingGoal? {
        dataSource.savingGoal
    }

    let dataSource: IncomeDataSourceProtocol
    
    init(dataSource: IncomeDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func load() async throws {
        try? await dataSource.readAllDeposits()
        try? await dataSource.readGoal()
    }

    func createSavingGoal(_ goal: SavingGoal) async throws {
        try? await dataSource.create(goal)
    }

    func createDeposit(_ deposit: Deposit) async throws {
        try? await dataSource.create(deposit)
    }

    func updateSavingGoal(with newValue: SavingGoal) async throws {
        try? await dataSource.update(newValue)
    }

    func updateDeposit(with newValue: Deposit) async throws {
        try? await dataSource.update(newValue)
    }

    func deleteSavingGoal() async throws{
        guard let savingGoal else { return }
        try? await dataSource.delete(savingGoal)
    }

    func deleteDeposits(removeAt indices: IndexSet) async throws {
        let depositsToDelete = indices.compactMap { deposits.indices.contains($0) ? deposits[$0] : nil }
        try? await dataSource.deleteAll(depositsToDelete)
    }

    func deleteDeposit(_ deposit: Deposit) async throws {
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
