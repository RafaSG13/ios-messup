//
//  ContentView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct ExpensesView: View {
    @Environment(\.expenseVM) var expensesVM
    @State private var lastExpenses: [Expense] = []
    @State private var shouldPresentAddExpense = false
    @State private var shouldPresentEditExpense = false
    @State private var selectedItem: Expense?

    private enum ViewTraits {
        static let headerSpacing: CGFloat = 10
    }

    private enum Constants {
        static let maximumNumberOfExpenses = 6
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    AnalyticsSection()
                        .padding()

                    LazyVStack(spacing: ViewTraits.headerSpacing) {
                        ListSectionHeaderView(sectionTitle: "Transactions",
                                              route: .transactionList)
                        .padding(.horizontal)

                        MUCustomVerticalForEach(items: $lastExpenses,
                                                selection: $selectedItem) { expense in
                            ExpenseCellView(expense: expense)
                        }
                        onDelete: { expense, _ in
                            Task { try await expensesVM.delete(expense) }
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
                ToolbarItem(placement: .primaryAction) {
                    Button("", systemImage: "plus") {
                        shouldPresentAddExpense.toggle()
                    }.buttonStyle(.plain)
                }
            }
            .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                             onSubmit: expensesVM.addExpense)
            .editExpenseSheet(isPresented: $shouldPresentEditExpense,
                              selectedItem: $selectedItem,
                              onSubmit: expensesVM.updateExpense(with:))
        }.task {
            lastExpenses = expensesVM.lastExpenses(limit: Constants.maximumNumberOfExpenses)
        }
    }
}

//MARK: - View Components

fileprivate struct AnalyticsSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Analytics")
                .font(.title2.bold())
            WeeklyExpensesView()
                .frame(height: 200)
        }
    }
}

#Preview {
    ExpensesView()
}
