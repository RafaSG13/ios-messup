//
//  ExpensesService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import SwiftUI

protocol ExpensesServiceProtocol: AnyObject {
    var expenses: [Expense] { get }
    func loadExpenses() async throws
    func addExpense(_ expense: Expense) async throws
    func delete(_ expense: Expense) async throws
    func delete(at offsets: IndexSet) async throws
    func updateExpense(with newValue: Expense) async throws
    func filteredExpenses(on searchTerm: String) -> [Expense]
    func getActualWeekExpenses() -> [Expense] 
}

extension EnvironmentValues {
    @Entry() var expenseService: ExpensesServiceProtocol = MockExpensesService()
}

@Observable
final class ExpensesService: ExpensesServiceProtocol {
    private(set) var expenses: [Expense] = []

    func loadExpenses() async throws {
        let request = GetAllExpensesRequest()
        self.expenses = try await MUClient().send(request, as: [Expense].self)
    }

    func addExpense(_ expense: Expense) async throws {
        let request = CreateExpenseRequest(expense: expense)
        let new = try await MUClient().send(request, as: Expense.self)
        self.expenses.append(new)
    }

    func delete(_ expense: Expense) async throws {
        let request = DeleteExpenseRequest(id: expense.id)
        _ = try await MUClient().send(request, as: Expense.self)
        self.expenses.removeAll(where: { $0.id == expense.id })
    }

    // TODO: At backend implement a api call to delete multiple expenses at once
    func delete(at offSets: IndexSet) async throws {
        let expensesToDelete = offSets.compactMap { expenses.indices.contains($0) ? expenses[$0] : nil }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for expense in expensesToDelete {
                group.addTask {
                    let request = DeleteExpenseRequest(id: expense.id)
                    _ = try await MUClient().send(request, as: Expense.self)
                }
            }
            try await group.waitForAll()
        }
        expenses.remove(atOffsets: offSets)
    }

    func updateExpense(with newValue: Expense) async throws {
        let request = UpdateExpenseRequest(expense: newValue)
        _ = try await MUClient().send(request, as: Expense.self)

        if let index = expenses.firstIndex(where: { $0.id == newValue.id }) {
            expenses[index] = newValue
        }
    }

    func filteredExpenses(on searchTerm: String) -> [Expense] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return expenses }
        return expenses.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }

    func getActualWeekExpenses() -> [Expense] {
        expenses.filter { expense in
            Calendar.current.isDateInThisWeek(expense.date)
        }
    }
}
