//
//  SavingDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation

protocol IncomeDataSourceProtocol {
    var deposits: [Deposit] { get set }
    var savingGoal: SavingGoal? { get set }

    func readAllDeposits() async throws
    func readGoal() async throws
    func create(_ goal: SavingGoal) async throws
    func create(_ deposit: Deposit) async throws
    func update(_ goal: SavingGoal) async throws
    func update(_ deposit: Deposit) async throws
    func delete(_ goal: SavingGoal) async throws
    func delete(_ deposit: Deposit) async throws
    func deleteAll(_ deposits: [Deposit]) async throws
}

class IncomeDataSource: IncomeDataSourceProtocol {

    var deposits: [Deposit] = []
    var savingGoal: SavingGoal? = nil

    func readAllDeposits() async throws {
        try await simulateNetworkDelay()
        self.deposits = Deposit.mockArray
    }

    func readGoal() async throws {
        try await simulateNetworkDelay()
        savingGoal = SavingGoal.mock
    }

    //TODO: Manage errors in guard statement, if goal already exists
    func create(_ goal: SavingGoal) async throws {
        guard savingGoal == nil else { return }

        try await simulateNetworkDelay()
        savingGoal = goal
    }

    func create(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        deposits.append(deposit)
    }

    func update(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        savingGoal = goal
    }

    func update(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        guard let index = deposits.firstIndex(where: { $0.id == deposit.id }) else {
            return
        }
        deposits[index] = deposit
    }
    
    func delete(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        savingGoal = nil
    }

    func delete(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        deposits.removeAll(where: { $0.id == deposit.id })
    }

    func deleteAll(_ deposits: [Deposit]) async throws {
        try await simulateNetworkDelay()
        self.deposits.removeAll(where: { deposits.contains($0) })
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
