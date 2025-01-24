//
//  SavingDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation



protocol SavingsDataSourceProtocol {
    func readAllDeposits() async throws -> [Deposit]
    func readGoal() async throws -> SavingGoal?
    func create(_ goal: SavingGoal) async throws
    func create(_ deposit: Deposit) async throws
    func update(_ goal: SavingGoal) async throws
    func update(_ deposit: Deposit) async throws
    func delete(_ goal: SavingGoal) async throws
    func deleteAll(_ deposits: [Deposit]) async throws
}

struct SavingDataSource: SavingsDataSourceProtocol {

    func readAllDeposits() async throws -> [Deposit] {
        try await simulateNetworkDelay()
        return Deposit.mockArray
    }

    func readGoal() async throws -> SavingGoal? {
        try await simulateNetworkDelay()
        return SavingGoal.mock
    }

    func create(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        SavingGoal.mock = goal
    }

    func create(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        Deposit.mockArray.append(deposit)
    }

    func update(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        SavingGoal.mock = goal
    }

    func update(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        guard let index = Deposit.mockArray.firstIndex(where: { $0.id == deposit.id }) else {
            return
        }
        Deposit.mockArray[index] = deposit
    }
    
    func delete(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        // Intentionally unimplemented
    }

    func deleteAll(_ deposits: [Deposit]) async throws {
        try await simulateNetworkDelay()
        Deposit.mockArray.removeAll(where: { deposits.contains($0) })
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
