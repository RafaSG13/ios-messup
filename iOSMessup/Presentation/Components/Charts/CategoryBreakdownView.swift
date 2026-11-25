//
//  CategoryBreakdownView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - CategoryBreakdownView

/// The biggest categories of a period as rows (icon, name, amount, share, bar proportional to the largest) plus an
/// "Other" row for the rest. Meant to live inside a card.
struct CategoryBreakdownView: View {
    /// Every category of the period, biggest first (`PeriodSummary.categoryTotals`).
    let totals: [CategoryTotal]
    var limit = 5
    /// Monthly-limit progress per category; absent when it has no limit or the period is not a month with a budget.
    var limitProgress: [Category: BudgetProgress] = [:]

    var body: some View {
        let split = CategoryTotal.topCategories(totals, limit: limit)
        let total = totals.reduce(0) { $0 + $1.amount }
        let largest = max(split.top.first?.amount ?? 0, split.other)

        VStack(alignment: .leading, spacing: MUSpacer.size04) {
            ForEach(split.top) { item in
                let progress = limitProgress[item.category]
                CategoryBreakdownRow(icon: item.category.icon,
                                     color: item.category.color,
                                     title: Text(item.category.rawValue),
                                     amount: item.amount,
                                     share: total > 0 ? item.amount / total : 0,
                                     barFraction: largest > 0 ? item.amount / largest : 0,
                                     barTint: progress.map { $0.state == .ok ? item.category.color : $0.state.tint }
                                         ?? item.category.color,
                                     limitProgress: progress)
            }
            if split.other > 0 {
                CategoryBreakdownRow(icon: "ellipsis",
                                     color: .gray,
                                     title: Text("Other"),
                                     amount: split.other,
                                     share: total > 0 ? split.other / total : 0,
                                     barFraction: largest > 0 ? split.other / largest : 0,
                                     barTint: .gray,
                                     limitProgress: nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - CategoryBreakdownRow

private struct CategoryBreakdownRow: View {
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconTileSize: CGFloat = 36
    let icon: String
    let color: Color
    let title: Text
    let amount: Double
    let share: Double
    let barFraction: Double
    let barTint: Color
    let limitProgress: BudgetProgress?

    var body: some View {
        HStack(alignment: .top, spacing: MUSpacer.size03) {
            MUIconTile(systemImage: icon, tint: color, size: iconTileSize)

            VStack(alignment: .leading, spacing: MUSpacer.size02) {
                CategoryHeadline(title: title, amount: amount, share: share)
                ProgressBar(progress: barFraction, tint: barTint)
                    .accessibilityHidden(true)
                if let limitProgress {
                    Text("\(limitProgress.spent.formattedMoney(code: currencyCode)) of \(limitProgress.limit.formattedMoney(code: currencyCode))")
                        .font(.caption)
                        .foregroundStyle(limitProgress.state == .ok ? Color.secondary : limitProgress.state.tint)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - CategoryHeadline

/// Not an `MUAdaptiveStack`: the `Spacer` of the regular layout must not expand vertically.
private struct CategoryHeadline: View {
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let title: Text
    let amount: Double
    let share: Double

    var body: some View {
        let amountText = Text(amount.formattedMoney(code: currencyCode))
        let shareText = Text(share, format: .percent.precision(.fractionLength(0)))

        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: MUSpacer.size01) {
                title.font(.subheadline)
                amountText.font(.subheadline.bold())
                shareText.font(.caption).foregroundStyle(.secondary)
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: MUSpacer.size03) {
                title.font(.subheadline)
                Spacer(minLength: MUSpacer.size03)
                amountText.font(.subheadline.bold())
                shareText
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Previews

#Preview("Mock data") {
    MUCard("Categories") {
        CategoryBreakdownView(totals: Expense.mockArray.totalsByCategory(),
                              limit: 3,
                              limitProgress: Dictionary(uniqueKeysWithValues: Budget.mock.categoryLimits.map {
                                  ($0.key, BudgetProgress(spent: 450, limit: $0.value))
                              }))
    }
    .padding()
}

#Preview("Accessibility size") {
    ScrollView {
        MUCard("Categories") {
            CategoryBreakdownView(totals: Expense.mockArray.totalsByCategory(), limit: 3)
        }
        .padding()
    }
    .dynamicTypeSize(.accessibility3)
}
