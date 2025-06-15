//
//  ExpensesDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation

protocol ExpensesDataSourceProtocol {
    var expenses: [Expense] { get set }
    func readAll() async throws
    func create(_ expense: Expense) async throws
    func update(_ expense: Expense) async throws
    func delete(_ expense: Expense) async throws
    func deleteAll(_ expenses: [Expense]) async throws
}

class ExpensesDataSource: ExpensesDataSourceProtocol {
    var expenses: [Expense] = []

    func readAll() async throws {
        let request = GetAllExpensesRequest()
        expenses = try await MUClient().send(request, as: [Expense].self)
    }

    func create(_ expense: Expense) async throws {
        let request = CreateExpenseRequest(expense: expense)
        let newExpense = try await MUClient().send(request, as: Expense.self)
        expenses.append(newExpense)
    }

    func delete(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        expenses.removeAll(where: { $0.id == expense.id })
    }

    func deleteAll(_ expenses: [Expense]) async throws {
        try await simulateNetworkDelay()
        self.expenses.removeAll(where: { expenses.contains($0) })
    }

    func update(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else {
            return
        }
        expenses[index] = expense
    }

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 3_000_000_000)
    }
}
