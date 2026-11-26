//
//  ExpensesService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import SwiftData
import SwiftUI

protocol ExpensesServiceProtocol: AnyObject {
    var expenses: [Expense] { get }
    func loadExpenses() async throws
    func addExpense(_ expense: Expense) async throws
    func delete(_ expense: Expense) async throws
    func delete(at offsets: IndexSet) async throws
    func updateExpense(with newValue: Expense) async throws
    func filteredExpenses(on searchTerm: String) -> [Expense]
    func lastExpenses(limit: Int) -> [Expense]
}

extension EnvironmentValues {
    @Entry var expenseService: ExpensesServiceProtocol = defaultExpenseService
    // A `static let`: the macro's getter runs on every fallback read, so `MockExpensesService()` there would allocate a new service each time.
    private static let defaultExpenseService = MockExpensesService()
}

@Observable
final class ExpensesService: ExpensesServiceProtocol {
    private(set) var expenses: [Expense] = []
    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func loadExpenses() async throws {
        try reload()
    }

    func addExpense(_ expense: Expense) async throws {
        let context = store.context
        context.insert(ExpenseRecord(expense))
        try context.save()
        try reload()
    }

    func delete(_ expense: Expense) async throws {
        try deleteRecords(withIDs: [expense.id])
    }

    func delete(at offSets: IndexSet) async throws {
        let ids = offSets.compactMap { expenses.indices.contains($0) ? expenses[$0].id : nil }
        try deleteRecords(withIDs: ids)
    }

    func updateExpense(with newValue: Expense) async throws {
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<ExpenseRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(newValue)
        try context.save()
        try reload()
    }

    // MARK: - Persistence

    private func deleteRecords(withIDs ids: [String]) throws {
        let context = store.context
        let records = try context.fetch(FetchDescriptor<ExpenseRecord>(predicate: #Predicate { ids.contains($0.id) }))
        records.forEach { context.delete($0) }
        try context.save()
        try reload()
    }

    private func reload() throws {
        let descriptor = FetchDescriptor<ExpenseRecord>(sortBy: [SortDescriptor(\.date)])
        expenses = try store.context.fetch(descriptor).map(\.domain)
    }

    // MARK: - Derived

    func filteredExpenses(on searchTerm: String) -> [Expense] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return expenses }
        return expenses.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }

    func lastExpenses(limit: Int) -> [Expense] {
        expenses.sorted().suffix(limit)
    }
}
