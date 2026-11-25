//
//  BalanceSummaryCard.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - BalanceSummaryCard

/// Balance of a period (income − expenses + net debts) with its three components.
struct BalanceSummaryCard: View {
    @Environment(\.currencyCode) private var currencyCode
    let summary: PeriodSummary

    var body: some View {
        MUCard("Balance") {
            VStack(alignment: .leading, spacing: MUSpacer.size04) {
                BalanceHeaderView(balance: summary.balance)
                Divider()
                MUAdaptiveStack(alignment: .top) {
                    MUMetricLabel("Income",
                                  systemImage: "arrow.down.circle.fill",
                                  value: "+" + summary.income.formattedCompactMoney(code: currencyCode))
                    MUMetricLabel("Expenses",
                                  systemImage: "creditcard.fill",
                                  value: "−" + summary.spent.formattedCompactMoney(code: currencyCode))
                    MUMetricLabel("Debts",
                                  systemImage: "person.2.fill",
                                  value: (summary.debtFlow >= 0 ? "+" : "−")
                                      + abs(summary.debtFlow).formattedCompactMoney(code: currencyCode))
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text("Balance is income minus expenses plus net money from debts."))
        }
    }
}

// MARK: - BalanceHeaderView

private struct BalanceHeaderView: View {
    @Environment(\.currencyCode) private var currencyCode
    let balance: Double

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            MUHeroAmount(balance.formattedMoney(code: currencyCode),
                         value: balance,
                         tint: balance < 0 ? Color.designSystem.critical : .primary)
            if balance < 0 {
                Text("over")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("left to spend")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Positive") {
    let period = Period(kind: .month, containing: .now)
    BalanceSummaryCard(summary: PeriodSummary(period: period,
                                              expenses: Expense.mockArray,
                                              incomes: Income.mockArray,
                                              debts: []))
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Over, accessibility size") {
    let period = Period(kind: .month, containing: .now)
    BalanceSummaryCard(summary: PeriodSummary(period: period,
                                              expenses: Expense.mockArray,
                                              incomes: [],
                                              debts: []))
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(\.dynamicTypeSize, .accessibility3)
}
