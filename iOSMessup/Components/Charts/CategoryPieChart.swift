//
//  CategoryPieChart.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI
import Charts

struct CategoryPieChart: View {
    var expenses: [Expense]
    var body: some View {
        Chart {
            ForEach(calculateAmountPerCategory(), id: \.0) { category, amount in
                SectorMark(angle: .value(category.rawValue, amount), angularInset: 1)
                    .foregroundStyle(category.color.opacity(0.9))

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func calculateAmountPerCategory() -> [(Category, Double)] {
        return expenses.reduce(into: [Category: Double]()) { result, expense in
            result[expense.category, default: 0] += expense.amount
        }.map { key, value in (key, value) }
    }
}


#Preview {
    GeometryReader { proxy in
        ScrollView(.horizontal) {
            LazyHStack {
                CategoryPieChart(expenses: Expense.mockArray)
                    .frame(width: proxy.size.width - 40)
                    .frame(maxHeight: .infinity)

                WeeklyExpensesView()
                    .frame(width: proxy.size.width)

            }
 
        }.scrollTargetBehavior(.paging)
            .padding(20)
    }
}
