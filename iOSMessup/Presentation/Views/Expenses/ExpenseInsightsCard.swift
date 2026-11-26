//
//  ExpenseInsightsCard.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpenseInsightsCard

/// One localized sentence with a symbol per `Insight`.
struct ExpenseInsightsCard: View {
    @Environment(\.intelligenceService) private var intelligenceService

    let insights: [Insight]
    let summary: PeriodSummary
    /// The overall monthly limit, `nil` outside months or without a budget.
    let monthlyLimit: Double?

    var body: some View {
        MUCard("Insights") {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: MUSpacer.size04) {
                    ForEach(insights, id: \.self) { insight in
                        InsightRowView(insight: insight, kind: summary.period.kind)
                    }
                }
                if intelligenceService.availability == .available {
                    Spacer(minLength: MUSpacer.size04)
                    Divider()
                    InsightsSummaryView(summary: summary, monthlyLimit: monthlyLimit)
                        .padding(.top, MUSpacer.size04)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

// MARK: - InsightRowView

private struct InsightRowView: View {
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric(relativeTo: .subheadline) private var iconWidth: CGFloat = 20
    let insight: Insight
    let kind: PeriodKind

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: MUSpacer.size03) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
                .frame(width: iconWidth)
                .accessibilityHidden(true)
            sentence
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private var symbol: String {
        switch insight {
        case .topCategory(let category, _): category.icon
        case .changeVersusPrevious(let change): change < 0 ? "arrow.down.right" : "arrow.up.right"
        case .projection: "chart.line.uptrend.xyaxis"
        case .dailyAverage: "calendar"
        }
    }

    private var sentence: Text {
        switch insight {
        case .topCategory(let category, let share):
            let percent = share.formatted(.percent.precision(.fractionLength(0)))
            return Text("\(category.rawValue) is your top category, \(percent) of your spending")
        case .changeVersusPrevious(let change):
            return kind.changeText(change)
        case .projection(let projected, let limit):
            let amount = projected.formattedMoney(code: currencyCode)
            guard let limit else { return Text("At this pace you will spend \(amount) by the end of the period") }
            let limitText = limit.formattedMoney(code: currencyCode)
            return projected > limit
                ? Text("At this pace you will spend \(amount), over your \(limitText) budget")
                : Text("At this pace you will spend \(amount), within your \(limitText) budget")
        case .dailyAverage(let average):
            return Text("You spend \(average.formattedMoney(code: currencyCode)) per day on average")
        }
    }
}

// MARK: - InsightsSummaryView

/// Apple Intelligence summary of the period. Streamed text re-renders only this view.
private struct InsightsSummaryView: View {
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var generatedSummary = ""
    @State private var summaryTask: Task<Void, Never>?
    @State private var error: (any Error)?

    let summary: PeriodSummary
    let monthlyLimit: Double?

    var body: some View {
        Group {
            if generatedSummary.isEmpty && summaryTask == nil {
                Button("Summarize", systemImage: "sparkles", action: summarize)
                    .buttonStyle(.bordered)
            } else {
                VStack(alignment: .leading, spacing: MUSpacer.size03) {
                    if generatedSummary.isEmpty {
                        ProgressView()
                    } else {
                        Text(generatedSummary)
                            .font(.subheadline)
                    }
                    IntelligenceDisclaimer()
                }
            }
        }
        .onChange(of: summary.period) { resetSummary() }
        .onChange(of: summary.spent) { resetSummary() }
        .errorAlert($error)
    }

    private func summarize() {
        let stream = intelligenceService.summarize(summary, monthlyLimit: monthlyLimit, currencyCode: currencyCode)
        summaryTask = Task {
            do {
                for try await text in stream {
                    generatedSummary = text
                }
            } catch is CancellationError {
            } catch {
                self.error = error
            }
            summaryTask = nil
        }
    }

    /// A summary of another period or of different figures would be stale.
    private func resetSummary() {
        summaryTask?.cancel()
        summaryTask = nil
        generatedSummary = ""
    }
}

// MARK: - Previews

#Preview("Insights") {
    ExpenseInsightsCard(insights: [.projection(2400, budgetLimit: 2000),
                                   .changeVersusPrevious(-0.12),
                                   .topCategory(.food, share: 0.42)],
                        summary: ExpenseInsightsCard.previewSummary(kind: .month),
                        monthlyLimit: 2000)
        .padding()
}

#Preview("Apple Intelligence off") {
    ExpenseInsightsCard(insights: [.dailyAverage(40)],
                        summary: ExpenseInsightsCard.previewSummary(kind: .month),
                        monthlyLimit: nil)
        .padding()
        .environment(\.intelligenceService, MockIntelligenceService(availability: .deviceNotEligible))
}

#Preview("Accessibility size") {
    ScrollView {
        ExpenseInsightsCard(insights: [.projection(1200, budgetLimit: nil),
                                       .dailyAverage(40),
                                       .changeVersusPrevious(0.3)],
                            summary: ExpenseInsightsCard.previewSummary(kind: .week),
                            monthlyLimit: nil)
            .padding()
    }
    .dynamicTypeSize(.accessibility3)
}

private extension ExpenseInsightsCard {
    static func previewSummary(kind: PeriodKind) -> PeriodSummary {
        PeriodSummary(period: Period(kind: kind, containing: .now),
                      expenses: Expense.mockArray,
                      incomes: [],
                      debts: [])
    }
}
