//
//  WeeklyExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import Charts
import MUDesignSystem

// MARK: - WeeklyExpensesView

/// Bar chart with the amount spent on each weekday of the current week. Meant to live inside a card.
struct WeeklyExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.currencyCode) private var currencyCode

    var body: some View {
        let data = buildData(for: expenseService.getActualWeekExpenses())

        Chart {
            ForEach(data, id: \.day) { day, amount in
                BarMark(
                    x: .value("Day", day),
                    y: .value("Spent", amount)
                )
                .foregroundStyle(Color.accentColor)
                .cornerRadius(MURadius.small)
                .annotation(position: .top) {
                    if amount > 0 {
                        Text(amount.formattedCompactMoney(code: currencyCode))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis(.hidden)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityLabel("Spending in the last 7 days")
        .accessibilityValue(accessibilitySummary(for: data))
    }
}

// MARK: - Auxiliary Methods

extension WeeklyExpensesView {
    func buildData(for weeklyExpenses: [Expense]) -> [(day: String, amount: Double)] {
        (1...7).map { weekday in
            let dayName = Calendar.current.shortWeekdaySymbols[weekday - 1]
            let amount = weeklyExpenses
                .filter { Calendar.current.component(.weekday, from: $0.date) == weekday }
                .reduce(0) { $0 + $1.amount }
            return (day: dayName, amount: amount)
        }
    }

    private func accessibilitySummary(for data: [(day: String, amount: Double)]) -> String {
        data.filter { $0.amount > 0 }
            .map { "\($0.day): \($0.amount.formattedMoney(code: currencyCode))" }
            .joined(separator: ", ")
    }
}

// MARK: - Previews

#Preview("Mock data") {
    MUCard("Last 7 days") {
        WeeklyExpensesView()
            .frame(height: 200)
    }
    .padding()
}

#Preview("Empty") {
    MUCard("Last 7 days") {
        WeeklyExpensesView()
            .frame(height: 200)
    }
    .padding()
    .environment(\.expenseService, MockExpensesService(initialExpenses: [], delay: 0))
}
