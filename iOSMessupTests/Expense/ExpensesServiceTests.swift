//
//  ExpensesServiceTests.swift
//  iOSMessup
//
//  Created by AI Assistant on 12/4/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct ExpensesServiceTests {

    @Test func loadExpenses() async throws {
        let mockService = MockExpensesService(initialExpenses: [])

        try await mockService.loadExpenses()

        #expect(mockService.expenses.isEmpty)
    }

    @Test func addExpense() async throws {
        let mockService = MockExpensesService(initialExpenses: [])
        let newExpense = Expense.mock

        try await mockService.addExpense(newExpense)

        #expect(mockService.expenses.contains(newExpense))
        #expect(mockService.expenses.count == 1)
    }

    @Test func updateExpense() async throws {
        let initialExpense = Expense.mock
        let mockService = MockExpensesService(initialExpenses: [initialExpense])

        let updatedExpense = Expense(
            id: initialExpense.id,
            name: "Updated Name",
            amount: 999.99,
            date: initialExpense.date,
            paymentMethod: initialExpense.paymentMethod,
            category: initialExpense.category
        )

        try await mockService.updateExpense(with: updatedExpense)

        #expect(mockService.expenses.contains(updatedExpense))
        #expect(!mockService.expenses.contains(initialExpense))
        #expect(mockService.expenses.first?.name == "Updated Name")
    }

    @Test func deleteExpense() async throws {
        let expense = Expense.mock
        let mockService = MockExpensesService(initialExpenses: [expense])

        try await mockService.delete(expense)

        #expect(mockService.expenses.isEmpty)
        #expect(!mockService.expenses.contains(expense))
    }

    @Test func filteredExpenses() async throws {
        let expenses = [
            Expense(name: "Apple Store", amount: 100, date: Date(), paymentMethod: .cash, category: .technology),
            Expense(name: "Grocery Store", amount: 50, date: Date(), paymentMethod: .cash, category: .food)
        ]
        let mockService = MockExpensesService(initialExpenses: expenses)

        let filtered = mockService.filteredExpenses(on: "Apple")

        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Apple Store")
    }

    @Test func filteredExpensesShortSearchTerm() async throws {
        let expenses = Expense.mockArray
        let mockService = MockExpensesService(initialExpenses: expenses)

        let filtered = mockService.filteredExpenses(on: "Ap")

        #expect(filtered.count == expenses.count)
    }

    @Test func getActualWeekExpenses() async throws {
        let actualWeekExpense = Expense(
            name: "Today Expense",
            amount: 100,
            date: Date(),
            paymentMethod: .cash,
            category: .food
        )
        let lastWeekExpense = Expense(
            name: "Last Week",
            amount: 50,
            date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!,
            paymentMethod: .cash,
            category: .food
        )
        let mockService = MockExpensesService(initialExpenses: [actualWeekExpense, lastWeekExpense])

        let weekExpenses = mockService.getActualWeekExpenses()

        #expect(weekExpenses.count == 1)
        #expect(weekExpenses.first?.name == "Today Expense")
    }

    @Test func addExpenseFailure() async throws {
        let mockService = MockExpensesService(initialExpenses: [], shouldFail: true)

        await #expect(throws: Error.self) {
            try await mockService.addExpense(Expense.mock)
        }
    }

    @Test func calculateTotalExpenses() async throws {
        let expenses = [
            Expense.mock,
            Expense.mock
        ]
        let mockService = MockExpensesService(initialExpenses: expenses)

        let total = mockService.expenses.reduce(0) { $0 + $1.amount }

        #expect(total == Expense.mock.amount * 2)
    }
}
