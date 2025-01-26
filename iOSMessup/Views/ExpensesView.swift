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
        static let generalViewPadding: CGFloat = 20
        static let interSectionSpacing: CGFloat = 28
        static let headerSpacing: CGFloat = 10
    }

    private enum Constants {
        static let maximumNumberOfExpenses = 8
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ViewTraits.interSectionSpacing) {
                    TotalBalanceCardView(total: expensesVM.calculateTotalSpent())
                        .frame(height: 150)
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        HStack {
                            Text("Analytics")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        WeeklyExpensesView()
                            .frame(height: 150)
                    }
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        ListSectionHeaderView(sectionTitle: "Transactions", destination: AnyView(AllExpensesView()))
                        VStack(spacing: 15) {
                            ForEach(expensesVM.lastExpenses(limit: Constants.maximumNumberOfExpenses)) { expense in
                                ExpenseCellView(expense: expense)
                                    .selectableCell {
                                        selectedItem = expense
                                    }
                                    .onChange(of: selectedItem) { _, newValue in
                                            shouldPresentEditExpense = newValue != nil
                                    }
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .padding(ViewTraits.generalViewPadding)
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
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
        }
    }
}

#Preview {
    ExpensesView()
}
