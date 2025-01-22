//
//  AllExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AllExpensesView: View {
    @Binding var expenses: [Expense]
    @State private var selectedItem: Expense?
    @State var shouldPresentEditExpense = false
    @State var shouldPresentAddExpense = false

    var body: some View {
        List($expenses, id: \.self, editActions: [.delete], selection: $selectedItem) { $expense in
            ExpenseCellView(expense: expense)
                .listRowSeparator(.hidden)
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
        .onChange(of: selectedItem) { _, newValue in
            guard newValue != nil else { return }
            shouldPresentEditExpense.toggle()
        }
        .sheet(isPresented: $shouldPresentEditExpense, onDismiss: resetSelectedItem) {
            if let selectedID = selectedItem?.id,
               let index = expenses.firstIndex(where: { $0.id == selectedID }) {
                EditExpenseModalView(expense: $expenses[index])
            } else {
                Text("No expense selected.")
            }
        }
        .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                         expenses: $expenses)
    }
}

private extension AllExpensesView {
    func resetSelectedItem() {
        selectedItem = nil
    }
}

#Preview {
    AllExpensesView(expenses: .constant(Expense.mockArray))
}
