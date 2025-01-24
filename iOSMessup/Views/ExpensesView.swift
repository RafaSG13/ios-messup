//
//  ContentView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import Charts

struct ExpensesView: View {
    @Environment(ExpenseViewModel.self) var expensesVM
    @State private var shouldPresentAddExpense = false

    private enum ViewTraits {
        static let generalViewPadding: CGFloat = 20
        static let interSectionSpacing: CGFloat = 28
        static let headerSpacing: CGFloat = 10
    }

    private enum Constants {
        static let maximumNumberOfExpenses = 5
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ViewTraits.interSectionSpacing) {
                    TotalBalanceCardView(total: expensesVM.calculateTotalSpent())
                        .frame(height: 150)
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        AnalyticsHeader
                        WeeklyExpensesView()
                            .frame(height: 150)
                    }
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        TransactionsHeader
                        VStack(spacing: 15) {
                            ForEach(expensesVM.lastExpenses(limit: Constants.maximumNumberOfExpenses)) { expense in
                                ExpenseCellView(expense: expense)
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
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
        }
    }
}

//MARK: - View Components

extension ExpensesView {
    var TransactionsHeader: some View {
        ListSectionHeaderView(sectionTitle: "Transactions", destination: AnyView(AllExpensesView()))
    }

    var AnalyticsHeader: some View {
        HStack {
            Text("Analytics")
                .font(.title2)
                .bold()
            Spacer()
        }
    }
}

#Preview {
    ExpensesView()
        .environment(ExpenseViewModel(dataSource: ExpensesDataSourceSpy()))
}
