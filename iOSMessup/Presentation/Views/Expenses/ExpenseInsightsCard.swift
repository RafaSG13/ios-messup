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
    @Environment(\.currencyCode) private var currencyCode

    let insights: [Insight]
    let kind: PeriodKind

    var body: some View {
        MUCard("Insights") {
            VStack(alignment: .leading, spacing: MUSpacer.size04) {
                ForEach(insights.indices, id: \.self) { index in
                    row(for: insights[index])
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Rows

private extension ExpenseInsightsCard {
    func row(for insight: Insight) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: MUSpacer.size03) {
            Image(systemName: symbol(for: insight))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            sentence(for: insight)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    func symbol(for insight: Insight) -> String {
        switch insight {
        case .topCategory(let category, _): category.icon
        case .changeVersusPrevious(let change): change < 0 ? "arrow.down.right" : "arrow.up.right"
        case .projection: "chart.line.uptrend.xyaxis"
        case .dailyAverage: "calendar"
        }
    }

    func sentence(for insight: Insight) -> Text {
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

// MARK: - Previews

#Preview("Insights") {
    ExpenseInsightsCard(insights: [.projection(2400, budgetLimit: 2000),
                                   .changeVersusPrevious(-0.12),
                                   .topCategory(.food, share: 0.42)],
                        kind: .month)
        .padding()
}

#Preview("Accessibility size") {
    ScrollView {
        ExpenseInsightsCard(insights: [.projection(1200, budgetLimit: nil),
                                       .dailyAverage(40),
                                       .changeVersusPrevious(0.3)],
                            kind: .week)
            .padding()
    }
    .dynamicTypeSize(.accessibility3)
}
