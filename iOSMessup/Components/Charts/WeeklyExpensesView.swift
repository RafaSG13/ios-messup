//
//  WeeklyExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import Charts

struct WeeklyExpensesView: View {
    @Environment(\.expenseRepository) var expenseRepository

    var body: some View {
        let data = buildData(for: expenseRepository.getActualWeekExpenses())

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
                            .padding(MUSpacer.size02)
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
    func buildData(for weeklyExpenses: [Expense]) -> [(day: String, amount: Double)] {
        (1...7).map { weekday in
            let dayName = Calendar.current.shortWeekdaySymbols[weekday - 1]
            let amount = weeklyExpenses
                .filter { Calendar.current.component(.weekday, from: $0.date) == weekday }
                .reduce(0) { $0 + $1.amount }
            return (day: dayName, amount: amount)
        }
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
    WeeklyExpensesView()
}
