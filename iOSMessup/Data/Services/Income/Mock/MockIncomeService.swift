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
    private(set) var incomes: [Income]
    var delay: TimeInterval
    var shouldFail: Bool

    init(initialIncomes: [Income] = Income.mockArray,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.incomes = initialIncomes
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

    func createIncome(_ income: Income) async throws {
        try await simulateNetwork()
        incomes.append(income)
    }

    func updateIncome(with newValue: Income) async throws {
        try await simulateNetwork()
        if let index = incomes.firstIndex(where: { $0.id == newValue.id }) {
            incomes[index] = newValue
        }
    }

    func deleteIncome(_ income: Income) async throws {
        try await simulateNetwork()
        incomes.removeAll(where: { $0.id == income.id })
    }

    func lastIncomes(limit: Int) -> [Income] {
        Array(incomes.sorted().suffix(limit))
    }

    func filteredIncomes(on searchTerm: String) -> [Income] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return incomes }
        return incomes.filter { $0.concept.localizedCaseInsensitiveContains(searchTerm) }
    }
}
