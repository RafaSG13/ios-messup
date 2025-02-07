//
//  ExpenseViewModelProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//
import Observation
import SwiftUI

protocol ExpenseViewModelProtocol: AnyObject, Observable {
    var expenses: [Expense] { get }
    func loadExpenses() async throws
    func lastExpenses(limit: Int) -> [Expense]
    func getActualWeekExpenses() -> [Expense]
    func calculateTotalSpent() -> Double
    func filteredExpenses(on searchTerm: String) -> [Expense] 
    func updateExpense(with newValue: Expense) async throws
    func addExpense(_ expense: Expense) async throws
    func delete(removeAt indices: IndexSet) async throws
    func delete(_ expense: Expense) async throws
}

extension EnvironmentValues {
    @Entry() var expenseVM: ExpenseViewModelProtocol = ExpenseViewModelMock()
}
