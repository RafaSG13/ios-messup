//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import MUDesignSystem

struct AllExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @State private var selectedItem: Expense?
    @State private var shouldPresentEditExpense = false
    @State private var shouldPresentAddExpense = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        List {
            ForEach(expenseService.filteredExpenses(on: searchText)) { expense in
                ExpenseCellView(expense: expense)
                    .selectableCell {
                        selectedItem = expense
                    }
                    .onChange(of: selectedItem) { _, newValue in
                        shouldPresentEditExpense = newValue != nil
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 7.5, leading: 20, bottom: 7.5, trailing: 20))
            }.onDelete { indexSet in
                let displayed = expenseService.filteredExpenses(on: searchText)
                let expensesToDelete = indexSet.map { displayed[$0] }
                Task {
                    do {
                        for expense in expensesToDelete {
                            try await expenseService.delete(expense)
                        }
                    } catch {
                        self.error = error
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .toolbar)
        .searchToolbarBehavior(.minimize)
        .scrollIndicators(.hidden)
        .navigationTitle("All transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add expense", systemImage: "plus") {
                    shouldPresentAddExpense.toggle()
                }
                .buttonStyle(.glassProminent)
            }
        }
        .errorAlert($error)
        .editExpenseSheet(isPresented: $shouldPresentEditExpense,
                          selectedItem: $selectedItem,
                          onSubmit: expenseService.updateExpense(with:))
        .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                         onSubmit: expenseService.addExpense)
    }
}

#Preview {
    NavigationStack {
        AllExpensesView()
    }
}
