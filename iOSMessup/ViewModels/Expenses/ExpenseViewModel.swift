//
//  ExpenseViewModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation
import Observation
import SwiftUI

protocol ExpenseViewModelProtocol {
    var expenses: [Expense] { get }
    func loadExpenses() async throws
    func lastExpenses(limit: Int) -> [Expense]
    func getActualWeekExpenses() -> [Expense]
    func calculateTotalSpent() -> Double
    func updateExpense(with newValue: Expense) async throws
    func addExpense(_ expense: Expense) async throws
    func delete(removeAt indices: IndexSet) async throws
}

@Observable class ExpenseViewModel: ExpenseViewModelProtocol {
    private(set) var expenses: [Expense] = []
    let dataSource: ExpensesDataSourceProtocol
    
    init(dataSource: ExpensesDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func loadExpenses() async throws {
        expenses = try await dataSource.readAll()
    }
    
    func lastExpenses(limit: Int) -> [Expense] {
        return expenses.sorted().suffix(limit)
    }

    func calculateTotalSpent() -> Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }

    func getActualWeekExpenses() -> [Expense] {
        expenses.filter { expense in
            Calendar.current.isDateInThisWeek(expense.date)
        }
    }

    func updateExpense(with newValue: Expense) async throws {
        if let index = expenses.firstIndex(where: { $0.id == newValue.id }) {
            expenses[index] = newValue
            try? await dataSource.update(newValue)
        }
    }

    func addExpense(_ expense: Expense) async throws{
        expenses.append(expense)
        try? await dataSource.create(expense)
    }

    func delete(removeAt indices: IndexSet) async throws{
        let expensesToDelete = indices.compactMap { expenses.indices.contains($0) ? expenses[$0] : nil }
        expenses.remove(atOffsets: indices)
        try? await dataSource.deleteAll(expensesToDelete)
    }
}
