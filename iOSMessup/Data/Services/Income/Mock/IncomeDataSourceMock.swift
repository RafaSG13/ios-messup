//
//  SavingViewModelMock.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation

/// This mock is mainly used to compile `Previews`. This is not intended to use in production code or even in testing.
@Observable class IncomeDataSourceMock: IncomeDataSourceProtocol {

    var deposits: [Deposit]
    var savingGoal: SavingGoal?
    var shouldThrowError: Bool

    enum MockError: Error {
        case operationFailed
    }

    init(initialDeposits: [Deposit] = Deposit.mockArray,
         initialGoal: SavingGoal? = SavingGoal.mock,
         shouldThrowError: Bool = false) {
        self.deposits = initialDeposits
        self.savingGoal = initialGoal
        self.shouldThrowError = shouldThrowError
    }

    /// Simulates a network delay and optionally throws an error.
    private func simulateNetworkDelay() async throws {
        if shouldThrowError {
            throw MockError.operationFailed
        }
        // Simulate a 0.2 second delay
        try await Task.sleep(nanoseconds: 200_000_000)
    }

    // MARK: - Protocol Implementation

    func readAllDeposits() async throws {
        try await simulateNetworkDelay()
    }

    func readGoal() async throws {
        try await simulateNetworkDelay()
    }

    func create(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        self.savingGoal = goal
    }

    func create(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        self.deposits.append(deposit)
    }

    func update(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        self.savingGoal = goal
    }

    func update(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        guard let index = self.deposits.firstIndex(where: { $0.id == deposit.id }) else {
            return
        }
        self.deposits[index] = deposit
    }

    func delete(_ goal: SavingGoal) async throws {
        try await simulateNetworkDelay()
        self.savingGoal = nil
    }

    func delete(_ deposit: Deposit) async throws {
        try await simulateNetworkDelay()
        self.deposits.removeAll { $0.id == deposit.id }
    }

    func deleteAll(_ deposits: [Deposit]) async throws {
        try await simulateNetworkDelay()
        let idsToDelete = Set(deposits.map { $0.id })
        self.deposits.removeAll { idsToDelete.contains($0.id) }
    }

    // MARK: - Synchronous Methods

    func lastDeposits(limit: Int) -> [Deposit] {
        Array(deposits.suffix(limit))
    }

    func calculateTotalFounded() -> Double {
        deposits.reduce(0) { $0 + $1.amount }
    }

    func calculateActualProgress() -> Double {
        guard let savingGoal, savingGoal.amount > 0 else { return 0 }
        return calculateTotalFounded() / savingGoal.amount
    }

    func filteredDeposits(on searchTerm: String) -> [Deposit] {
        guard !searchTerm.isEmpty, searchTerm.count >= 3 else { return deposits }
        return deposits.filter { $0.concept.lowercased().contains(searchTerm.lowercased()) }
    }
}
