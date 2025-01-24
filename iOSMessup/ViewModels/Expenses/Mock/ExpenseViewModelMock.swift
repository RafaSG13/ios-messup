//
//  ExpenseViewModelMock.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation

@Observable class ExpenseViewModelMock: ExpenseViewModelProtocol {
    var expenses: [Expense] = Expense.mockArray
    
    func loadExpenses() async throws {
        // Intentionally unimplemented
    }
    
    func lastExpenses(limit: Int) -> [Expense] {
        Expense.mockArray.suffix(limit)
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
        // Intentionally unimplemented
    }
    
    func addExpense(_ expense: Expense) {
        // Intentionally unimplemented

    }
    
    func delete(removeAt indices: IndexSet) {
        // Intentionally unimplemented
    }
}
