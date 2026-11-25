//
//  ExpensesSummaryCard.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpensesSummaryCard

/// Spent in the period, the change versus the previous one, the projection while it is in progress and, for months,
/// the budget row (or a "Set a budget" button). Tapping the budget row calls `onEditBudget`.
struct ExpensesSummaryCard: View {
    @Environment(\.currencyCode) private var currencyCode

    let summary: PeriodSummary
    /// Only months have a budget; other periods never show the budget row.
    let showsBudget: Bool
    let budgetProgress: BudgetProgress?
    let onEditBudget: () -> Void

    var body: some View {
        MUCard("Spent") {
            VStack(alignment: .leading, spacing: MUSpacer.size03) {
                Text(summary.spent.formattedMoney(code: currencyCode))
                    .font(MUTypography.heroAmount)
                    .contentTransition(.numericText(value: summary.spent))
                    .animation(.snappy, value: summary.spent)

                if let change = summary.changeVersusPrevious {
                    Label {
                        summary.period.kind.changeText(change)
                    } icon: {
                        Image(systemName: change < 0 ? "arrow.down.right" : "arrow.up.right")
                    }
                    .font(.subheadline)
                    .foregroundStyle(change < 0 ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.designSystem.warning))
                }
                if let projected = summary.projectedSpent {
                    Text("On pace for \(projected.formattedMoney(code: currencyCode))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if showsBudget {
                    budgetRow
                        .padding(.top, MUSpacer.size02)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Budget

private extension ExpensesSummaryCard {
    @ViewBuilder
    var budgetRow: some View {
        if let budgetProgress {
            Button(action: onEditBudget) {
                VStack(alignment: .leading, spacing: MUSpacer.size03) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Budget")
                            .font(.subheadline.bold())
                        Spacer(minLength: MUSpacer.size03)
                        remainingText(for: budgetProgress)
                            .font(.subheadline)
                            .foregroundStyle(tint(for: budgetProgress.state))
                    }
                    ProgressBar(progress: budgetProgress.fraction, tint: tint(for: budgetProgress.state))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Edit budget")
        } else {
            Button("Set a budget", systemImage: "target", action: onEditBudget)
                .buttonStyle(.bordered)
        }
    }

    func remainingText(for progress: BudgetProgress) -> Text {
        let amount = abs(progress.remaining).formattedMoney(code: currencyCode)
        return progress.remaining >= 0 ? Text("\(amount) left") : Text("\(amount) over")
    }

    func tint(for state: BudgetProgress.State) -> Color {
        switch state {
        case .ok: Color.accentColor
        case .warning: Color.designSystem.warning
        case .over: Color.designSystem.critical
        }
    }
}

// MARK: - PeriodKind

extension PeriodKind {
    /// "12% less than last month" for `-0.12`, "12% more than last month" for `0.12`.
    func changeText(_ change: Double) -> Text {
        let percent = abs(change).formatted(.percent.precision(.fractionLength(0)))
        switch (self, change < 0) {
        case (.week, true): return Text("\(percent) less than last week")
        case (.week, false): return Text("\(percent) more than last week")
        case (.month, true): return Text("\(percent) less than last month")
        case (.month, false): return Text("\(percent) more than last month")
        case (.year, true): return Text("\(percent) less than last year")
        case (.year, false): return Text("\(percent) more than last year")
        }
    }
}

// MARK: - Previews

private extension ExpensesSummaryCard {
    static var previewSummary: PeriodSummary {
        PeriodSummary(period: Period(kind: .month, containing: .now),
                      expenses: Expense.mockArray,
                      incomes: [],
                      contributions: [])
    }
}

#Preview("Budget warning") {
    ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                        showsBudget: true,
                        budgetProgress: BudgetProgress(spent: 1700, limit: 2000),
                        onEditBudget: {})
        .padding()
}

#Preview("No budget") {
    ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                        showsBudget: true,
                        budgetProgress: nil,
                        onEditBudget: {})
        .padding()
}

#Preview("Over, accessibility size") {
    ScrollView {
        ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                            showsBudget: true,
                            budgetProgress: BudgetProgress(spent: 2300, limit: 2000),
                            onEditBudget: {})
            .padding()
    }
    .dynamicTypeSize(.accessibility3)
}
