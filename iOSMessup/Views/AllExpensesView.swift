//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AllExpensesView: View {
    @Environment(\.expenseVM) var expensesVM
    @State private var selectedItem: Expense?
    @State private var shouldPresentEditExpense = false
    @State private var shouldPresentAddExpense = false
    @State private var searchText = ""
    @State private var searchScope: Category? = nil
    
    var body: some View {
        List {
            ForEach(expensesVM.filteredExpenses(on: searchText)) { expense in
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
                Task {
                    try await expensesVM.delete(removeAt: indexSet)
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
        .editExpenseSheet(isPresented: $shouldPresentEditExpense,
                          selectedItem: $selectedItem,
                          onSubmit: expensesVM.updateExpense(with:))
        .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                         onSubmit: expensesVM.addExpense)
    }
}

#Preview {
    NavigationStack {
        AllExpensesView()
    }
}
