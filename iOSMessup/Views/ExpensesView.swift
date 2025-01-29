//
//  ContentView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct ExpensesView: View {
    @Environment(\.expenseVM) var expensesVM
    @State private var shouldPresentAddExpense = false
    @State private var shouldPresentEditExpense = false
    @State private var selectedItem: Expense?

    private enum ViewTraits {
        static let headerSpacing: CGFloat = 10
    }

    private enum Constants {
        static let maximumNumberOfExpenses = 8
    }

    var body: some View {
        @State var lastExpenses = expensesVM.lastExpenses(limit: Constants.maximumNumberOfExpenses)
        NavigationStack {
            ScrollView {
                LazyVStack {
                    TotalBalanceCardView(total: expensesVM.calculateTotalSpent())
                        .frame(height: 150)
                        .padding(.horizontal)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: ViewTraits.headerSpacing) {
                        Text("Analytics")
                            .font(.title2.bold())
                        WeeklyExpensesView()
                            .frame(height: 150)
                    }.padding()

                    VStack(spacing: ViewTraits.headerSpacing) {
                        ListSectionHeaderView(sectionTitle: "Transactions", route: .transactionList)
                            .padding(.horizontal)

                        MUCustomVerticalForEach(items: lastExpenses,
                                                selection: $selectedItem) { expense in
                            ExpenseCellView(expense: expense)
                        } onTap: { _ in }
                        onDelete: { indexSet in
                            Task {
                                try await expensesVM.delete(removeAt: indexSet)
                            }
                        }
                        .onChange(of: selectedItem) { _, new in
                            shouldPresentEditExpense = new != nil
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "line.horizontal.3")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldPresentAddExpense.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }.buttonStyle(.plain)
                }
            }
            .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                             onSubmit: expensesVM.addExpense)
            .editExpenseSheet(isPresented: $shouldPresentEditExpense,
                              selectedItem: $selectedItem,
                              onSubmit: expensesVM.updateExpense(with:))
        }
    }
}

#Preview {
    ExpensesView()
}
