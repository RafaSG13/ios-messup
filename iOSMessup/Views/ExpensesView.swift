//
//  ContentView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import Charts

struct ExpensesView: View {

    @State var expenses: [Expense] = Expense.mockArray

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
                    TotalBalanceCardView()
                        .frame(height: 150)
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        AnalyticsHeader
                        WeeklyExpensesView(expenses: expenses)
                            .frame(height: 150)
                    }
                    
                    VStack(spacing: ViewTraits.headerSpacing) {
                        TransactionsHeader
                        VStack(spacing: 15) {
                            ForEach(expenses.sorted().suffix(Constants.maximumNumberOfExpenses)) { expense in
                                ExpenseCellView(expense: expense)
                            }
                        }
                    }
                }
                .padding(ViewTraits.generalViewPadding)
                .navigationTitle("Expenses")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "line.horizontal.3")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // Display add expense modal
                        } label: {
                            Image(systemName: "plus")
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
    }
}

extension ExpensesView {
    var TransactionsHeader: some View {
        HStack {
            Text("Transactions")
                .font(.title2)
                .bold()
            Spacer()
            Button("View all") {
                //Navigate to full list view
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
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
}
