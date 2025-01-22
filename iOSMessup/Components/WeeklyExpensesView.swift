//
//  WeeklyExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import Charts

struct WeeklyExpensesView: View {
    @State var expenses: [Expense]

    var body: some View {
        let data = buildData(for: getActualWeekExpenses())
        Chart {
            ForEach(data, id: \.day) { day, amount in
                BarMark(
                    x: .value("Day", day),
                    y: .value("Spent", amount)
                )
                .foregroundStyle(getExpenseChartColor(for: amount))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Auxiliary Methods

extension WeeklyExpensesView {
    func getActualWeekExpenses() -> [Int: Double] {
        let weeklyExpenses = expenses.filter { expense in
            Calendar.current.isDateInThisWeek(expense.date)
        }
        
        let groupedExpenses = Dictionary(grouping: weeklyExpenses) { expense in
            Calendar.current.component(.weekday, from: expense.date)
        }
        .mapValues { $0.reduce(0) { $0 + $1.amount } }
        return groupedExpenses
    }

    func buildData(for expensesPerDay: [Int: Double]) -> [(day: String, amount: Double)] {
        let data = (1...7).map { weekday in
            let dayName = Calendar.current.shortWeekdaySymbols[weekday - 1]
            let amount = expensesPerDay[weekday] ?? 0
            return (day: dayName, amount: amount)
        }
        return data
    }

    func getExpenseChartColor(for amount: Double) -> Color {
        return switch amount {
        case 0..<100: .green
        case 100..<500: .yellow
        case 500...: .red
        default: .clear
        }
    }
}

#Preview {
    WeeklyExpensesView(expenses: Expense.mockArray)
}
