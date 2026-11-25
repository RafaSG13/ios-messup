//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - AllExpensesView

struct AllExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @State private var selectedItem: Expense?
    @State private var shouldPresentAddExpense = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        let sections = expenseService.filteredExpenses(on: searchText).groupedByDay(date: \.date)

        List {
            if sections.isEmpty {
                emptyState
            }
            ForEach(sections) { section in
                Section {
                    ForEach(section.items) { expense in
                        ExpenseCellView(expense: expense)
                            .selectableCell { selectedItem = expense }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) { delete(expense) }
                            }
                    }
                } header: {
                    Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide))
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(MUSpacer.size04)
        .searchable(text: $searchText, placement: .toolbar)
        .searchToolbarBehavior(.minimize)
        .navigationTitle("All transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add expense", systemImage: "plus") {
                    shouldPresentAddExpense = true
                }
                .buttonStyle(.glassProminent)
            }
        }
        .errorAlert($error)
        .editExpenseSheet(item: $selectedItem,
                          onSubmit: expenseService.updateExpense(with:))
        .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                         onSubmit: expenseService.addExpense)
    }
}

// MARK: - View Components

private extension AllExpensesView {
    @ViewBuilder
    var emptyState: some View {
        Group {
            if searchText.isEmpty {
                ContentUnavailableView {
                    Label("No transactions", systemImage: "creditcard")
                } description: {
                    Text("Add your first expense to see it here.")
                } actions: {
                    Button("Add expense") { shouldPresentAddExpense = true }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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
    NavigationStack {
        AllExpensesView()
    }
}

#Preview("Empty") {
    NavigationStack {
        AllExpensesView()
            .environment(\.expenseService, MockExpensesService(initialExpenses: [], delay: 0))
    }
}

#Preview("Failing service") {
    NavigationStack {
        AllExpensesView()
            .environment(\.expenseService, MockExpensesService(delay: 0, shouldFail: true))
    }
}
