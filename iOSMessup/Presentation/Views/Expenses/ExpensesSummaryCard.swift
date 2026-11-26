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
/// the budget row (or a "Set a budget" button). Tapping the budget row presents the budget form.
struct ExpensesSummaryCard: View {
    @Environment(\.currencyCode) private var currencyCode

    let summary: PeriodSummary
    /// Only months have a budget; other periods never show the budget row.
    let showsBudget: Bool
    let budgetProgress: BudgetProgress?
    @Binding var isPresentingBudget: Bool

    var body: some View {
        MUCard("Spent") {
            VStack(alignment: .leading, spacing: MUSpacer.size03) {
                MUHeroAmount(summary.spent.formattedMoney(code: currencyCode), value: summary.spent)

                if summary.changeVersusPrevious != nil || summary.projectedSpent != nil {
                    VStack(alignment: .leading, spacing: MUSpacer.size01) {
                        if let change = summary.changeVersusPrevious {
                            HStack(alignment: .firstTextBaseline, spacing: MUSpacer.size02) {
                                Image(systemName: change < 0 ? "arrow.down.right" : "arrow.up.right")
                                summary.period.kind.changeText(change)
                            }
                            .font(.subheadline)
                            .foregroundStyle(change < 0
                                             ? AnyShapeStyle(.secondary)
                                             : AnyShapeStyle(Color.designSystem.warning))
                            .accessibilityElement(children: .combine)
                        }
                        if let projected = summary.projectedSpent {
                            Text("On pace for \(projected.formattedMoney(code: currencyCode))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if summary.spent > 0 {
                    SpendBarsChart(bars: summary.spendBars, currentBar: summary.currentBar)
                        .frame(minHeight: 56, idealHeight: 72, maxHeight: .infinity)
                } else if showsBudget {
                    Spacer(minLength: 0)
                }
                if showsBudget {
                    BudgetRowView(progress: budgetProgress, isPresentingBudget: $isPresentingBudget)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - BudgetRowView

private struct BudgetRowView: View {
    @Environment(\.currencyCode) private var currencyCode
    let progress: BudgetProgress?
    @Binding var isPresentingBudget: Bool

    var body: some View {
        if let progress {
            let amount = abs(progress.remaining).formattedMoney(code: currencyCode)

            Button {
                isPresentingBudget = true
            } label: {
                VStack(alignment: .leading, spacing: MUSpacer.size03) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Budget")
                            .font(.subheadline.bold())
                        Spacer(minLength: MUSpacer.size03)
                        Group {
                            if progress.remaining >= 0 {
                                Text("\(amount) left")
                            } else {
                                Text("\(amount) over")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(progress.state.tint)
                    }
                    ProgressBar(progress: progress.fraction, tint: progress.state.tint)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Edit budget")
        } else {
            Button("Set a budget", systemImage: "target") {
                isPresentingBudget = true
            }
            .buttonStyle(.bordered)
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
                      debts: [])
    }
}

#Preview("Budget warning") {
    ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                        showsBudget: true,
                        budgetProgress: BudgetProgress(spent: 1700, limit: 2000),
                        isPresentingBudget: .constant(false))
        .padding()
}

#Preview("No budget") {
    ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                        showsBudget: true,
                        budgetProgress: nil,
                        isPresentingBudget: .constant(false))
        .padding()
}

#Preview("Over, accessibility size") {
    ScrollView {
        ExpensesSummaryCard(summary: ExpensesSummaryCard.previewSummary,
                            showsBudget: true,
                            budgetProgress: BudgetProgress(spent: 2300, limit: 2000),
                            isPresentingBudget: .constant(false))
            .padding()
    }
    .dynamicTypeSize(.accessibility3)
}
