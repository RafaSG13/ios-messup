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

        VStack(spacing: 20) {
            // Header
            HStack {
                Spacer()
                Text("Last 7 days")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            // Chart
            Chart {
                ForEach(data, id: \.day) { day, amount in
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Spent", amount)
                    )
                    .foregroundStyle(getExpenseChartColor(for: amount))
                    .cornerRadius(5)
                    .annotation(position: .top) {
                        amount == 0
                        ? nil
                        : Text("$\(String(format: "%.2f", amount))")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(4)
                            .cornerRadius(4)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                }
            }
            .chartYAxis(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            LinearGradient(
                  gradient: Gradient(colors: [
                    Color.blue.opacity(1),
                    Color.darkGreen.opacity(1),
                  ]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
            ).shadow(color: .black, radius: 10, x: 0, y: 10)
        )
        .cornerRadius(20)
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
