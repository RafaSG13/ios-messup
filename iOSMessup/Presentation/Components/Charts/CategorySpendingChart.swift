//
//  CategorySpendingChart.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI
import Charts
import MUDesignSystem

// MARK: - CategorySpendingChart

/// Donut chart with one sector per category plus a legend (icon, name, amount). Meant to live inside a card.
struct CategorySpendingChart: View {
    @Environment(\.currencyCode) private var currencyCode
    let totals: [CategoryTotal]

    private enum ViewTraits {
        static let chartHeight: CGFloat = 180
    }

    var body: some View {
        VStack(spacing: MUSpacer.size04) {
            Chart(totals) { total in
                SectorMark(angle: .value("Amount", total.amount),
                           innerRadius: .ratio(0.6),
                           angularInset: 1)
                    .cornerRadius(MURadius.small)
                    .foregroundStyle(total.category.color)
            }
            .chartLegend(.hidden)
            .frame(height: ViewTraits.chartHeight)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: MUSpacer.size03) {
                ForEach(totals) { total in
                    HStack(spacing: MUSpacer.size03) {
                        Image(systemName: total.category.icon)
                            .foregroundStyle(total.category.color)
                            .symbolVariant(.fill)
                            .frame(width: MUSpacer.size05)
                            .accessibilityHidden(true)
                        Text(total.category.rawValue)
                            .font(.subheadline)
                        Spacer(minLength: MUSpacer.size03)
                        Text(total.amount.formattedMoney(code: currencyCode))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spending by category")
    }
}

// MARK: - Previews

#Preview("Mock data") {
    MUCard("Spending by category") {
        CategorySpendingChart(totals: Expense.mockArray.totalsByCategory())
    }
    .padding()
}

#Preview("Accessibility size") {
    ScrollView {
        MUCard("Spending by category") {
            CategorySpendingChart(totals: Expense.mockArray.totalsByCategory())
        }
        .padding()
    }
    .dynamicTypeSize(.accessibility3)
}
