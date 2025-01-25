//
//  ExpenseViewModelTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation
@testable import iOSMessup
import Testing

struct ExpenseViewModelTests {

    @Test func addNewExpense() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)
        let newExpense = Expense.mock

        try? await sut.addExpense(newExpense)

        #expect(spy.createCalled == true)
        #expect(sut.expenses.contains(newExpense))
    }

    @Test func updateExpenseWithNewValue() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)

        guard let newExpenseId = sut.expenses.first?.id else { return }
        let newExpense = Expense(id: newExpenseId, name: "", amount: 1, date: .now, paymentMethod: .cash, category: .food)
        try? await sut.updateExpense(with: newExpense)

        #expect(spy.updateCalled == true)
        #expect(sut.expenses.contains(newExpense))
    }

    @Test func deleteFromLocalAndRemoteSources() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)

        try? await sut.addExpense(Expense.mock)
        try? await sut.delete(removeAt: .init(integer: 0))

        #expect(spy.createCalled == true)
        #expect(spy.deleteAllCalled == true)
        #expect(!sut.expenses.contains(Expense.mock))
        #expect(sut.expenses.count == 0)
    }

    @Test func loadExpensesFromNetwork() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)

        spy.setReadAllResponse([Expense.mock, Expense.mock, Expense.mock])
        try? await sut.loadExpenses()

        #expect(spy.readAllCalled == true)
        #expect(sut.expenses.count == 3)
    }

    @Test func calculateTotalSpent() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)
        
        spy.setReadAllResponse([Expense.mock, Expense.mock, Expense.mock])
        try? await sut.loadExpenses()
        let totalSpent = sut.calculateTotalSpent()
        
        #expect(spy.readAllCalled == true)
        #expect(totalSpent == (Expense.mock.amount * 3))
    }

    @Test func lastExpensesWithLimit() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)
        let newExpense = Expense(id: UUID().uuidString,
                                 name: "Last Expense",
                                 amount: 1,
                                 date: .now.addingTimeInterval(1),
                                 paymentMethod: .cash,
                                 category: .food)

        spy.setReadAllResponse([newExpense, Expense.mock])
        try? await sut.loadExpenses()
        let lastExpenses = sut.lastExpenses(limit: 1)

        #expect(lastExpenses.count == 1)
        #expect(lastExpenses.first == newExpense)
    }

    @Test func getActualWeekExpenses() async throws {
        let spy = ExpensesDataSourceSpy()
        let sut = ExpenseViewModel(dataSource: spy)
        let actualWeekExpense = Expense(name: "Apple Store",
                                        amount: 329.99,
                                        date: Date(),
                                        paymentMethod: .creditCard,
                                        category: .technology)
        let nextWeekExpense = Expense(name: "Future Store",
                                      amount: 99.99,
                                      date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!,
                                      paymentMethod: .debitCard,
                                      category: .entertainment)

        let previousWeekExpense = Expense(name: "Last Week Coffee",
                                          amount: 4.99,
                                          date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!,
                                          paymentMethod: .cash,
                                          category: .food)
        spy.setReadAllResponse([actualWeekExpense, nextWeekExpense, previousWeekExpense])
        try? await sut.loadExpenses()

        let actualWeekExpenses = sut.getActualWeekExpenses()
        #expect(actualWeekExpenses.count == 1)
        #expect(actualWeekExpenses.first == actualWeekExpense)
    }
}
