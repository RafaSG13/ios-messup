//
//  MockExpensesService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Observation
import SwiftUI

@Observable
final class MockExpensesService: ExpensesServiceProtocol {
    private(set) var expenses: [Expense]
    var delay: TimeInterval
    var shouldFail: Bool

    init(initialExpenses: [Expense] = Expense.mockArray,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.expenses = initialExpenses
        self.delay = delay
        self.shouldFail = shouldFail
    }

    private func simulateNetwork() async throws {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        if shouldFail {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])
        }
    }

    func loadExpenses() async throws {
        try await simulateNetwork()
    }

    func addExpense(_ expense: Expense) async throws {
        try await simulateNetwork()
        expenses.append(expense)
    }

    func delete(_ expense: Expense) async throws {
        try await simulateNetwork()
        expenses.removeAll(where: { $0.id == expense.id })
    }

    func delete(at offsets: IndexSet) async throws {
        try await simulateNetwork()
        expenses.remove(atOffsets: offsets)
    }

    func updateExpense(with newValue: Expense) async throws {
        try await simulateNetwork()
        if let index = expenses.firstIndex(where: { $0.id == newValue.id }) {
            expenses[index] = newValue
        }
    }

    func filteredExpenses(on searchTerm: String) -> [Expense] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return expenses }
        return expenses.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }

    func getActualWeekExpenses() -> [Expense] {
        expenses.filter { Calendar.current.isDateInThisWeek($0.date) }
    }

    func lastExpenses(limit: Int) -> [Expense]{
        expenses.sorted().suffix(limit)
    }
}
