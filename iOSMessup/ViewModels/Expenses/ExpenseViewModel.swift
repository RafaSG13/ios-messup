//
//  ExpenseViewModel.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation
import Observation

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

    func filteredExpenses(on searchTerm: String) -> [Expense] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return expenses }
        return expenses.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
    }

    func updateExpense(with newValue: Expense) async throws {
        expenses = expenses.map { $0.id == newValue.id ? newValue : $0 }
        try await dataSource.update(newValue)
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

    func delete(_ expense: Expense) async throws {
        expenses.removeAll { $0.id == expense.id }
        try? await dataSource.delete(expense)
    }
}
