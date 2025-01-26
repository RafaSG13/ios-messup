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
    @State var shouldPresentEditExpense = false
    @State var shouldPresentAddExpense = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(expensesVM.expenses) { expense in
                    ExpenseCellView(expense: expense)
                        .selectableCell {
                            selectedItem = expense
                        }
                        .onChange(of: selectedItem) { _, newValue in
                            shouldPresentEditExpense = newValue != nil
                        }
//                    Button {
//                        selectedItem = expense
//                    } label: {
//                        ExpenseCellView(expense: expense)
//                            .onChange(of: selectedItem) { _, newValue in
//                                shouldPresentEditExpense = newValue != nil
//                            }
//                    }
//                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }.onDelete { indexSet in
                    Task {
                        try await expensesVM.delete(removeAt: indexSet)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
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
}
