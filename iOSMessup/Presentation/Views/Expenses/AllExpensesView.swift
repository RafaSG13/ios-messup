//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AllExpensesView: View {
    @Environment(\.expenseRepository) private var expenseRepository
    @State private var selectedItem: Expense?
    @State private var shouldPresentEditExpense = false
    @State private var shouldPresentAddExpense = false
    @State private var searchText = ""
    private let tasks = TaskStore()

    private enum TaskId { case deleteExpenses }

    var body: some View {
        List {
            ForEach(expenseRepository.filteredExpenses(on: searchText)) { expense in
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
                    try await expensesService.delete(at: indexSet)
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
                          onSubmit: expenseRepository.updateExpense(with:))
        .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                         onSubmit: expenseRepository.addExpense)
    }
}

#Preview {
    NavigationStack {
        AllExpensesView()
    }
}
