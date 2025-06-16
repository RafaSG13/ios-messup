//
//  ExpenseViewModelMock.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation
import Observation

/// This mock is mainly used to compile `Previews`. This is not intended to use in production code or even in testing.
// MARK: - Mock Data Source

@Observable class ExpensesDataSourceMock: ExpensesDataSourceProtocol {

    var expenses: [Expense]
    var shouldThrowError: Bool

    enum MockError: Error {
        case operationFailed
    }
    init(initialExpenses: [Expense] = Expense.mockArray, shouldThrowError: Bool = false) {
        self.expenses = initialExpenses
        self.shouldThrowError = shouldThrowError
    }

    private func simulateNetworkDelay() async throws {
        if shouldThrowError {
            throw MockError.operationFailed
        }
        try await Task.sleep(nanoseconds: 200_000_000)
    }


    func readAll() async throws {
        try await simulateNetworkDelay()
    }

    func create(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        self.expenses.append(expense)
    }

    func update(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        guard let index = self.expenses.firstIndex(where: { $0.id == expense.id }) else {
            return
        }
        self.expenses[index] = expense
    }

    func delete(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        self.expenses.removeAll { $0.id == expense.id }
    }

    func deleteAll(_ expensesToDelete: [Expense]) async throws {
        try await simulateNetworkDelay()
        let idsToDelete = Set(expensesToDelete.map { $0.id })
        self.expenses.removeAll { idsToDelete.contains($0.id) }
    }
}
