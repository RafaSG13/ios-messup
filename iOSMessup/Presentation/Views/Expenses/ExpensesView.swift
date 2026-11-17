//
//  ExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpensesView

struct ExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @State private var shouldPresentAddExpense = false
    @State private var selectedItem: Expense?
    @State private var error: (any Error)?

    private enum Constants {
        static let maximumNumberOfExpenses = 6
        static let categoryWindowInDays = 30
    }

    var body: some View {
        NavigationStack {
            List {
                if expenseService.expenses.isEmpty {
                    emptyState
                } else {
                    weeklySection
                    recentSection
                    categorySection
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { $0.destination }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add expense", systemImage: "plus") {
                        shouldPresentAddExpense = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .errorAlert($error)
            .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                             onSubmit: expenseService.addExpense)
            .editExpenseSheet(item: $selectedItem,
                              onSubmit: expenseService.updateExpense(with:))
        }
    }
}

// MARK: - View Components

private extension ExpensesView {
    var emptyState: some View {
        ContentUnavailableView {
            Label("No transactions", systemImage: "creditcard")
        } description: {
            Text("Add your first expense to see your spending here.")
        } actions: {
            Button("Add expense") { shouldPresentAddExpense = true }
                .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    var weeklySection: some View {
        Section {
            MUCard("Last 7 days") {
                WeeklyExpensesView()
                    .frame(height: 200)
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }

    var categorySection: some View {
        Section {
            MUCard("Spending by category") {
                if categoryTotals.isEmpty {
                    Text("No expenses in the last 30 days.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    CategorySpendingChart(totals: categoryTotals)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }

    var recentSection: some View {
        Section {
            ForEach(recentExpenses) { expense in
                Button {
                    selectedItem = expense
                } label: {
                    ExpenseCellView(expense: expense)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Delete", role: .destructive) { delete(expense) }
                }
            }
        } header: {
            ListSectionHeaderView(sectionTitle: "Transactions",
                                  actionTitle: "View all",
                                  value: Route.transactionList)
            .textCase(nil)
        }
    }
}

// MARK: - Data

private extension ExpensesView {
    /// Most recent first.
    var recentExpenses: [Expense] {
        Array(expenseService.lastExpenses(limit: Constants.maximumNumberOfExpenses).reversed())
    }

    var categoryTotals: [CategoryTotal] {
        let since = Calendar.current.date(byAdding: .day, value: -Constants.categoryWindowInDays, to: .now)
        return expenseService.expenses.totalsByCategory(since: since)
    }

    func delete(_ expense: Expense) {
        Task {
            do {
                try await expenseService.delete(expense)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Previews

#Preview("Mock data") {
    ExpensesView()
}

#Preview("Empty") {
    ExpensesView()
        .environment(\.expenseService, MockExpensesService(initialExpenses: [], delay: 0))
}

#Preview("Failing service") {
    ExpensesView()
        .environment(\.expenseService, MockExpensesService(delay: 0, shouldFail: true))
}
