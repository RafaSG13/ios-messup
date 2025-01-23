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
    func updateExpense(with newValue: Expense)
    func addExpense(_ expense: Expense)
    func delete(removeAt indices: IndexSet)
}

@Observable class ExpenseViewModel: ExpenseViewModelProtocol {
    var expenses: [Expense] = []
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

    func updateExpense(with newValue: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == newValue.id }) {
            expenses[index] = newValue
            Task {
                try? await dataSource.update(newValue)
            }
        }
    }

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        Task {
            try? await dataSource.create(expense)
        }
    }

    func delete(removeAt indices: IndexSet) {
        let expensesToDelete = indices.compactMap { expenses.indices.contains($0) ? expenses[$0] : nil }
        expenses.remove(atOffsets: indices)
        Task{
            try? await dataSource.deleteAll(expensesToDelete)
        }
    }
}
