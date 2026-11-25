//
//  CumulativeSpendingChart.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Charts
import SwiftUI
import MUDesignSystem

// MARK: - CumulativeSpendingChart

/// Cumulative spending of a period against the previous one. Dragging shows the day with both amounts; a dashed
/// rule marks the monthly limit when `monthlyLimit` is given. Meant to live inside a card.
struct CumulativeSpendingChart: View {
    @Environment(\.currencyCode) private var currencyCode
    @State private var selectedDay: Int?

    let summary: PeriodSummary
    /// Only passed for months with a budget.
    var monthlyLimit: Double?

    private enum ViewTraits {
        static let chartMinimumHeight: CGFloat = 200
        static let previousDash: [CGFloat] = [4, 3]
        static let limitDash: [CGFloat] = [6, 4]
        static let quarterMonthStep = 3
    }

    var body: some View {
        if summary.spent == 0 {
            Text("No expenses in this period.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            chart
        }
    }
}

// MARK: - Chart

private extension CumulativeSpendingChart {
    var dayCount: Int { summary.period.dayCount }

    var chart: some View {
        Chart {
            ForEach(summary.previousCumulativeSpend) { point in
                LineMark(x: .value("Day", point.day),
                         y: .value("Previous period", point.amount),
                         series: .value("Series", "Previous"))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: ViewTraits.previousDash))
            }
            ForEach(summary.cumulativeSpend) { point in
                AreaMark(x: .value("Day", point.day),
                         y: .value("Spent", point.amount),
                         series: .value("Series", "Area"))
                    .foregroundStyle(LinearGradient(colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0)],
                                                    startPoint: .top,
                                                    endPoint: .bottom))
                LineMark(x: .value("Day", point.day),
                         y: .value("Spent", point.amount),
                         series: .value("Series", "Current"))
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
            }
            if let monthlyLimit {
                RuleMark(y: .value("Monthly limit", monthlyLimit))
                    .foregroundStyle(Color.designSystem.warning)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: ViewTraits.limitDash))
                    .annotation(position: .top, alignment: .trailing, spacing: 2) {
                        Text("Limit \(monthlyLimit.formattedCompactMoney(code: currencyCode))")
                            .font(.caption2)
                            .foregroundStyle(Color.designSystem.warning)
                    }
            }
            if let day = selection {
                RuleMark(x: .value("Day", day))
                    .foregroundStyle(Color.secondary.opacity(0.5))
                    .annotation(position: .top,
                                spacing: 0,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        callout(for: day)
                    }
            }
        }
        .chartLegend(.hidden)
        .chartXScale(domain: 1...max(dayCount, 2))
        .chartPlotStyle { $0.clipped() }
        .chartXSelection(value: $selectedDay)
        .chartXAxis {
            AxisMarks(values: axisDays) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let day = value.as(Int.self) {
                        Text(axisLabel(for: day))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.formattedCompactMoney(code: currencyCode))
                    }
                }
            }
        }
        .frame(minHeight: ViewTraits.chartMinimumHeight)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cumulative spending")
        .accessibilityValue(accessibilitySummary)
    }

    /// The selected day clamped to the period.
    var selection: Int? {
        selectedDay.map { min(max($0, 1), dayCount) }
    }

    func callout(for day: Int) -> some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            Text(date(forDay: day), format: .dateTime.day().month(.abbreviated))
                .font(.caption.bold())
            if let current = amount(in: summary.cumulativeSpend, day: day) {
                Text("Spent \(current.formattedMoney(code: currencyCode))")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            if let previous = amount(in: summary.previousCumulativeSpend, day: day) {
                Text("Previous \(previous.formattedMoney(code: currencyCode))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(MUSpacer.size03)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: MURadius.small))
    }

    func amount(in points: [CumulativePoint], day: Int) -> Double? {
        points.first { $0.day == day }?.amount
    }
}

// MARK: - Axis & accessibility

private extension CumulativeSpendingChart {
    func date(forDay day: Int) -> Date {
        let calendar = summary.period.calendar
        return calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: summary.period.start))
            ?? summary.period.start
    }

    /// Few labels: every weekday for a week, every 7th day for a month, the first day of each quarter for a year.
    var axisDays: [Int] {
        switch summary.period.kind {
        case .week:
            return Array(1...max(dayCount, 1))
        case .month:
            return Array(stride(from: 1, through: dayCount, by: 7))
        case .year:
            let calendar = summary.period.calendar
            return (1...max(dayCount, 1)).filter { day in
                let components = calendar.dateComponents([.month, .day], from: date(forDay: day))
                return components.day == 1 && ((components.month ?? 1) - 1) % ViewTraits.quarterMonthStep == 0
            }
        }
    }

    func axisLabel(for day: Int) -> String {
        let dayDate = date(forDay: day)
        switch summary.period.kind {
        case .week: return dayDate.formatted(.dateTime.weekday(.abbreviated))
        case .month: return dayDate.formatted(.dateTime.day())
        case .year: return dayDate.formatted(.dateTime.month(.abbreviated))
        }
    }

    var accessibilitySummary: String {
        var parts = [String(localized: "Spent \(summary.spent.formattedMoney(code: currencyCode))")]
        if summary.previousSpent > 0 {
            parts.append(String(localized: "Previous period \(summary.previousSpent.formattedMoney(code: currencyCode))"))
        }
        if let monthlyLimit {
            parts.append(String(localized: "Monthly limit \(monthlyLimit.formattedMoney(code: currencyCode))"))
        }
        return parts.formatted(.list(type: .and, width: .narrow))
    }
}

// MARK: - Previews

private extension CumulativeSpendingChart {
    static func previewSummary(kind: PeriodKind) -> PeriodSummary {
        PeriodSummary(period: Period(kind: kind, containing: .now),
                      expenses: Expense.mockArray,
                      incomes: [],
                      contributions: [])
    }
}

#Preview("Month with limit") {
    MUCard("Spending") {
        CumulativeSpendingChart(summary: CumulativeSpendingChart.previewSummary(kind: .month), monthlyLimit: 2000)
    }
    .padding()
}

#Preview("Year") {
    MUCard("Spending") {
        CumulativeSpendingChart(summary: CumulativeSpendingChart.previewSummary(kind: .year))
    }
    .padding()
}

#Preview("Empty") {
    MUCard("Spending") {
        CumulativeSpendingChart(summary: PeriodSummary(period: Period(kind: .month, containing: .now),
                                                       expenses: [],
                                                       incomes: [],
                                                       contributions: []))
    }
    .padding()
}
