//
//  IncomeService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class IncomeService: IncomeServiceProtocol {
    private(set) var deposits: [Deposit] = []
    private(set) var savingGoal: SavingGoal?

    private let client: MUClientProtocol

    init(client: MUClientProtocol) {
        self.client = client
    }

    func load() async throws {
        // TODO: Replace with real API calls
        try await Task.sleep(for: .seconds(0.5))
        deposits = Deposit.mockArray
        savingGoal = SavingGoal.mock
    }

    func createSavingGoal(_ goal: SavingGoal) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        savingGoal = goal
    }

    func createDeposit(_ deposit: Deposit) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        deposits.append(deposit)
    }

    func updateSavingGoal(with newValue: SavingGoal) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        savingGoal = newValue
    }

    func updateDeposit(with newValue: Deposit) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        if let index = deposits.firstIndex(where: { $0.id == newValue.id }) {
            deposits[index] = newValue
        }
    }

    func deleteSavingGoal() async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        savingGoal = nil
    }

    func deleteDeposits(removeAt indices: IndexSet) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        let depositsToDelete = indices.compactMap { deposits.indices.contains($0) ? deposits[$0] : nil }
        deposits.removeAll(where: { depositsToDelete.contains($0) })
    }

    func deleteDeposit(_ deposit: Deposit) async throws {
        // TODO: Replace with real API call
        try await Task.sleep(for: .seconds(0.3))
        deposits.removeAll(where: { $0.id == deposit.id })
    }

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
