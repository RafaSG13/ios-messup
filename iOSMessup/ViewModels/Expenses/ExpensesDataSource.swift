//
//  ExpensesDataSource.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation


protocol ExpensesDataSourceProtocol {
    func readAll() async throws -> [Expense]
    func create(_ expense: Expense) async throws
    func update(_ expense: Expense) async throws
    func delete(_ expense: Expense) async throws
    func deleteAll(_ expenses: [Expense]) async throws
}

struct ExpensesDataSource: ExpensesDataSourceProtocol {
    func readAll() async throws -> [Expense] {
        try await simulateNetworkDelay()
        return Expense.mockArray
    }

    func create(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        Expense.mockArray.append(expense)
    }
    
    func delete(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        Expense.mockArray.removeAll(where: { $0.id == expense.id })
    }

    func deleteAll(_ expenses: [Expense]) async throws {
        try await simulateNetworkDelay()
        Expense.mockArray.removeAll(where: { expenses.contains($0) })
    }

    func update(_ expense: Expense) async throws {
        try await simulateNetworkDelay()
        guard let index = Expense.mockArray.firstIndex(where: { $0.id == expense.id }) else {
            return
        }
        Expense.mockArray[index] = expense
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: 3_000_000_000)
    }
}
