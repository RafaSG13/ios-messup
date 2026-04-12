//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AllExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @State private var selectedItem: Expense?
    @State private var shouldPresentEditExpense = false
    @State private var shouldPresentAddExpense = false
    @State private var searchText = ""
    private let tasks = TaskStore()

    private enum TaskId { case deleteExpenses }

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
                tasks.run(TaskId.deleteExpenses) {
                    try await expenseService.delete(at: indexSet)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .toolbar)
        .scrollIndicators(.hidden)
        .navigationTitle("All transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    shouldPresentAddExpense.toggle()
                } label: {
                    Image(systemName: "plus")
                }.buttonStyle(.plain)
            }
        }
        .onDisappear { tasks.cancelAll() }
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
