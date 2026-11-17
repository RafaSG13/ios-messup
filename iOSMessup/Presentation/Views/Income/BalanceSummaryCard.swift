//
//  BalanceSummaryCard.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - BalanceSummaryCard

/// Balance of a period (income − expenses − contributions) with its three components.
struct BalanceSummaryCard: View {
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let summary: PeriodSummary

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }
    private var isOver: Bool { summary.balance < 0 }

    var body: some View {
        MUCard("Balance") {
            VStack(alignment: .leading, spacing: MUSpacer.size04) {
                balanceHeader
                Divider()
                breakdown
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text("Balance is income minus expenses minus savings contributions."))
        }
    }
}

// MARK: - Subviews

private extension BalanceSummaryCard {
    var balanceHeader: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            Text(summary.balance.formattedMoney(code: currencyCode))
                .font(.largeTitle.bold())
                .foregroundStyle(isOver ? .red : .green)
                .minimumScaleFactor(0.6)
            if isOver {
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

    var breakdown: some View {
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(alignment: .top, spacing: MUSpacer.size03))
        return layout {
            BalanceLineView(title: "Income",
                            systemImage: "arrow.down.circle.fill",
                            sign: "+",
                            amount: summary.income,
                            tint: .green)
            BalanceLineView(title: "Expenses",
                            systemImage: "creditcard.fill",
                            sign: "−",
                            amount: summary.spent,
                            tint: .primary)
            BalanceLineView(title: "Saved",
                            systemImage: "banknote.fill",
                            sign: "−",
                            amount: summary.contributed,
                            tint: .primary)
        }
    }
}

// MARK: - BalanceLineView

private struct BalanceLineView: View {
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let title: LocalizedStringKey
    let systemImage: String
    let sign: String
    let amount: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            Label {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("\(sign)\(amount.formattedCompactMoney(code: currencyCode))")
                .font(.subheadline.bold())
                .foregroundStyle(tint)
                .minimumScaleFactor(0.7)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("Positive") {
    let period = Period(kind: .month, containing: .now)
    BalanceSummaryCard(summary: PeriodSummary(period: period,
                                              expenses: Expense.mockArray,
                                              incomes: Income.mockArray,
                                              contributions: []))
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Over, accessibility size") {
    let period = Period(kind: .month, containing: .now)
    BalanceSummaryCard(summary: PeriodSummary(period: period,
                                              expenses: Expense.mockArray,
                                              incomes: [],
                                              contributions: []))
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(\.dynamicTypeSize, .accessibility3)
}
