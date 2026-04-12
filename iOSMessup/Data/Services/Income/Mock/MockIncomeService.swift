//
//  MockIncomeService.swift
//  iOSMessup
//
//  Created by AI Assistant on 12/4/26.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class MockIncomeService: IncomeServiceProtocol {
    private(set) var deposits: [Deposit]
    private(set) var savingGoal: SavingGoal?
    var delay: TimeInterval
    var shouldFail: Bool
    
    init(initialDeposits: [Deposit] = Deposit.mockArray,
         initialGoal: SavingGoal? = SavingGoal.mock,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.deposits = initialDeposits
        self.savingGoal = initialGoal
        self.delay = delay
        self.shouldFail = shouldFail
    }
    
    private func simulateNetwork() async throws {
        try await Task.sleep(for: .seconds(delay))
        if shouldFail {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])
        }
    }
    
    func load() async throws {
        try await simulateNetwork()
    }
    
    func createSavingGoal(_ goal: SavingGoal) async throws {
        try await simulateNetwork()
        savingGoal = goal
    }
    
    func createDeposit(_ deposit: Deposit) async throws {
        try await simulateNetwork()
        deposits.append(deposit)
    }
    
    func updateSavingGoal(with newValue: SavingGoal) async throws {
        try await simulateNetwork()
        savingGoal = newValue
    }
    
    func updateDeposit(with newValue: Deposit) async throws {
        try await simulateNetwork()
        if let index = deposits.firstIndex(where: { $0.id == newValue.id }) {
            deposits[index] = newValue
        }
    }
    
    func deleteSavingGoal() async throws {
        try await simulateNetwork()
        savingGoal = nil
    }
    
    func deleteDeposits(removeAt indices: IndexSet) async throws {
        try await simulateNetwork()
        let depositsToDelete = indices.compactMap { deposits.indices.contains($0) ? deposits[$0] : nil }
        deposits.removeAll(where: { depositsToDelete.contains($0) })
    }
    
    func deleteDeposit(_ deposit: Deposit) async throws {
        try await simulateNetwork()
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
