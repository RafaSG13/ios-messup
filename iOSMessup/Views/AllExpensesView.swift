//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AllExpensesView: View {
    @Environment(ExpenseViewModel.self) var expensesVM
    @State private var selectedItem: Expense?
    @State var shouldPresentEditExpense = false
    @State var shouldPresentAddExpense = false

    var body: some View {
        List {
            ForEach(expensesVM.expenses, id: \.self) { expense in
                ExpenseCellView(expense: expense)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        selectedItem = expense
                    }
                    .onChange(of: selectedItem) {
                        guard selectedItem != nil else { return }
                        shouldPresentEditExpense = true
                    }
            }.onDelete { indexSet in
                expensesVM.delete(removeAt: indexSet)
            }
        }
        .listStyle(.plain)
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
    AllExpensesView()
        .environment(ExpenseViewModel(dataSource: ExpensesDataSourceSpy()))
}
