//
//  ExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import MUDesignSystem

struct ExpensesView: View {
    @Environment(\.expenseService) var expenseService
    @State private var lastExpenses: [Expense] = []
    @State private var shouldPresentAddExpense = false
    @State private var shouldPresentEditExpense = false
    @State private var selectedItem: Expense?
    @State private var error: (any Error)?

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
                                              actionTitle: "View all",
                                              value: Route.transactionList)
                        .padding(.horizontal)

                        MUCustomVerticalForEach(items: $lastExpenses,
                                                selection: $selectedItem,
                                                deleteTitle: "Delete") { expense in
                            ExpenseCellView(expense: expense)
                        }
                        onDelete: { expense, _ in
                            Task {
                                do {
                                    try await expenseService.delete(expense)
                                } catch {
                                    self.error = error
                                }
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
            .navigationDestination(for: Route.self) { $0.destination }
            .errorAlert($error)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add expense", systemImage: "plus") {
                        shouldPresentAddExpense.toggle()
                    }.buttonStyle(.plain)
                }
            }
            .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                             onSubmit: expenseService.addExpense)
            .editExpenseSheet(isPresented: $shouldPresentEditExpense,
                              selectedItem: $selectedItem,
                              onSubmit: expenseService.updateExpense(with:))
        }.onChange(of: expenseService.expenses, initial: true) {
            lastExpenses = expenseService.lastExpenses(limit: Constants.maximumNumberOfExpenses)
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
