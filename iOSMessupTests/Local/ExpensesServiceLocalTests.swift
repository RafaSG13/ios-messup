//
//  ExpensesServiceLocalTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

@MainActor
struct ExpensesServiceLocalTests {

    private func makeExpense(_ name: String, daysAgo: Int, amount: Double = 10) -> Expense {
        Expense(name: name,
                amount: amount,
                date: Date().addingTimeInterval(TimeInterval(-daysAgo * 86_400)),
                paymentMethod: .cash,
                category: .food)
    }

    @Test func addPersistsAcrossServiceInstances() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = ExpensesService(store: store)
        let expense = makeExpense("Coffee", daysAgo: 0)

        try await service.addExpense(expense)

        #expect(service.expenses == [expense])
        let other = ExpensesService(store: store)
        try await other.loadExpenses()
        #expect(other.expenses == [expense])
    }

    @Test func updateChangesAmountAndIgnoresUnknownId() async throws {
        let service = ExpensesService(store: LocalStore(storage: .inMemory))
        var expense = makeExpense("Coffee", daysAgo: 0, amount: 3)
        try await service.addExpense(expense)

        expense.amount = 4.5
        try await service.updateExpense(with: expense)
        #expect(service.expenses.first?.amount == 4.5)

        try await service.updateExpense(with: makeExpense("Ghost", daysAgo: 0))
        #expect(service.expenses == [expense])
    }

    @Test func deleteRemovesExpense() async throws {
        let service = ExpensesService(store: LocalStore(storage: .inMemory))
        let keep = makeExpense("Keep", daysAgo: 1)
        let drop = makeExpense("Drop", daysAgo: 0)
        try await service.addExpense(keep)
        try await service.addExpense(drop)

        try await service.delete(drop)

        #expect(service.expenses == [keep])
    }

    @Test func deleteAtOffsetsFollowsDateOrder() async throws {
        let service = ExpensesService(store: LocalStore(storage: .inMemory))
        let oldest = makeExpense("Oldest", daysAgo: 3)
        let middle = makeExpense("Middle", daysAgo: 2)
        let newest = makeExpense("Newest", daysAgo: 1)
        // Inserted out of order; the service orders by date ascending.
        try await service.addExpense(newest)
        try await service.addExpense(oldest)
        try await service.addExpense(middle)
        #expect(service.expenses == [oldest, middle, newest])

        try await service.delete(at: [0, 2])

        #expect(service.expenses == [middle])
    }

    @Test func filteredExpensesShortTermReturnsAll() async throws {
        let service = ExpensesService(store: LocalStore(storage: .inMemory))
        try await service.addExpense(makeExpense("Coffee", daysAgo: 1))
        try await service.addExpense(makeExpense("Rent", daysAgo: 0))

        #expect(service.filteredExpenses(on: "Ren").count == 2)
        #expect(service.filteredExpenses(on: "Cof").count == 2)
        #expect(service.filteredExpenses(on: "Coffee").map(\.name) == ["Coffee"])
    }

    @Test func expensesSurviveReopeningStoreOnDisk() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "t.store")
        let expense = makeExpense("Persisted", daysAgo: 0)

        do {
            let service = ExpensesService(store: LocalStore(storage: .file(url)))
            try await service.addExpense(expense)
        }

        let reopened = ExpensesService(store: LocalStore(storage: .file(url)))
        try await reopened.loadExpenses()
        #expect(reopened.expenses == [expense])
    }
}
