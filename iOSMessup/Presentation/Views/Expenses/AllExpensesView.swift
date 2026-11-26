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
        List {
            AllExpensesSections(searchText: searchText,
                                isPresentingAddExpense: $shouldPresentAddExpense,
                                selectedItem: $selectedItem,
                                error: $error)
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

// MARK: - AllExpensesSections

/// Reads and groups the expenses, so presenting a sheet or selecting a row (state of the screen root) does not
/// group every transaction again.
private struct AllExpensesSections: View {
    @Environment(\.expenseService) private var expenseService
    let searchText: String
    @Binding var isPresentingAddExpense: Bool
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?

    var body: some View {
        let sections = expenseService.filteredExpenses(on: searchText).groupedByDay(date: \.date)

        if sections.isEmpty {
            AllExpensesEmptyState(searchText: searchText, isPresentingAddExpense: $isPresentingAddExpense)
        }
        ForEach(sections) { section in
            Section {
                ForEach(section.items) { expense in
                    ExpenseListRow(expense: expense, selectedItem: $selectedItem, error: $error)
                }
            } header: {
                Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide))
            }
        }
    }
}

// MARK: - AllExpensesEmptyState

private struct AllExpensesEmptyState: View {
    let searchText: String
    @Binding var isPresentingAddExpense: Bool

    var body: some View {
        Group {
            if searchText.isEmpty {
                MUEmptyState("No transactions",
                             systemImage: "creditcard",
                             description: "Add your first expense to see it here.",
                             actionTitle: "Add expense") {
                    isPresentingAddExpense = true
                }
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .clearListRow()
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
