//
//  ExpenseViewModelProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//
import Observation
import SwiftUICore

protocol ExpenseViewModelProtocol: Observable {
    var expenses: [Expense] { get }
    func loadExpenses() async throws
    func lastExpenses(limit: Int) -> [Expense]
    func getActualWeekExpenses() -> [Expense]
    func calculateTotalSpent() -> Double
    func updateExpense(with newValue: Expense) async throws
    func addExpense(_ expense: Expense) async throws
    func delete(removeAt indices: IndexSet) async throws
}

struct ExpenseViewModelKey: EnvironmentKey {
    // you can also set the real user service as the default value
    static let defaultValue: any ExpenseViewModelProtocol = ExpenseViewModelMock()
}

extension EnvironmentValues {
    var expenseVM: any ExpenseViewModelProtocol {
        get { self[ExpenseViewModelKey.self] }
        set { self[ExpenseViewModelKey.self] = newValue }
    }
}
