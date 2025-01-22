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
    var body: some View {
        NavigationStack {
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
                    VStack {
                        ForEach(expenses.sorted().suffix(3)) { expense in
                            ExpenseCellView(expense: expense)
                        }
                    }
                }
                Spacer()
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
