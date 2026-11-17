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
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconTileSize: CGFloat = 36
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Every category of the period, biggest first (`PeriodSummary.categoryTotals`).
    let totals: [CategoryTotal]
    var limit = 5
    /// Progress of the category's monthly limit, `nil` when it has none (or outside a month with a budget).
    var limitProgress: (Category) -> BudgetProgress? = { _ in nil }

    var body: some View {
        let split = CategoryTotal.topCategories(totals, limit: limit)
        let total = totals.reduce(0) { $0 + $1.amount }
        let largest = max(split.top.first?.amount ?? 0, split.other)

        VStack(alignment: .leading, spacing: MUSpacer.size04) {
            ForEach(split.top) { item in
                let progress = limitProgress(item.category)
                row(icon: item.category.icon,
                    color: item.category.color,
                    title: Text(item.category.rawValue),
                    amount: item.amount,
                    share: share(of: item.amount, in: total),
                    barFraction: fraction(of: item.amount, in: largest),
                    barTint: tint(for: progress, default: item.category.color),
                    limitProgress: progress)
            }
            if split.other > 0 {
                row(icon: "ellipsis",
                    color: .gray,
                    title: Text("Other"),
                    amount: split.other,
                    share: share(of: split.other, in: total),
                    barFraction: fraction(of: split.other, in: largest),
                    barTint: .gray,
                    limitProgress: nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Rows

private extension CategoryBreakdownView {
    func row(icon: String,
             color: Color,
             title: Text,
             amount: Double,
             share: Double,
             barFraction: Double,
             barTint: Color,
             limitProgress: BudgetProgress?) -> some View {
        HStack(alignment: .top, spacing: MUSpacer.size03) {
            Image(systemName: icon)
                .symbolVariant(.fill)
                .foregroundStyle(color)
                .frame(width: iconTileSize, height: iconTileSize)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: MURadius.small))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: MUSpacer.size02) {
                headline(title: title, amount: amount, share: share)
                ProgressBar(progress: barFraction, tint: barTint)
                    .accessibilityHidden(true)
                if let limitProgress {
                    limitCaption(limitProgress)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    func headline(title: Text, amount: Double, share: Double) -> some View {
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

    func limitCaption(_ progress: BudgetProgress) -> some View {
        Text("\(progress.spent.formattedMoney(code: currencyCode)) of \(progress.limit.formattedMoney(code: currencyCode))")
            .font(.caption)
            .foregroundStyle(progress.state == .ok ? Color.secondary : tint(for: progress, default: .secondary))
    }

    func tint(for progress: BudgetProgress?, default color: Color) -> Color {
        switch progress?.state {
        case .warning: .orange
        case .over: .red
        case .ok, nil: color
        }
    }

    func share(of amount: Double, in total: Double) -> Double {
        total > 0 ? amount / total : 0
    }

    func fraction(of amount: Double, in largest: Double) -> Double {
        largest > 0 ? amount / largest : 0
    }
}

// MARK: - Previews

#Preview("Mock data") {
    MUCard("Categories") {
        CategoryBreakdownView(totals: Expense.mockArray.totalsByCategory(), limit: 3) { category in
            Budget.mock.categoryLimits[category].map { BudgetProgress(spent: 450, limit: $0) }
        }
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
