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
    let summary: PeriodSummary
    /// Only passed for months with a budget.
    var monthlyLimit: Double?

    var body: some View {
        if summary.spent == 0 {
            Text("No expenses in this period.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            CumulativeSpendingPlot(summary: summary, monthlyLimit: monthlyLimit)
        }
    }
}

// MARK: - CumulativeSpendingPlot

/// Owns the drag selection and the precomputed axis, so dragging only re-evaluates the chart.
private struct CumulativeSpendingPlot: View {
    @Environment(\.currencyCode) private var currencyCode
    @State private var selectedDay: Int?

    private let summary: PeriodSummary
    private let monthlyLimit: Double?
    private let axisDays: [Int]
    private let axisLabels: [Int: String]

    private enum ViewTraits {
        static let chartMinimumHeight: CGFloat = 200
        static let previousDash: [CGFloat] = [4, 3]
        static let limitDash: [CGFloat] = [6, 4]
    }

    init(summary: PeriodSummary, monthlyLimit: Double?) {
        self.summary = summary
        self.monthlyLimit = monthlyLimit

        let period = summary.period
        let dayCount = period.dayCount
        let days: [Int]
        // Few labels: every weekday for a week, every 7th day for a month, the first day of each quarter for a year.
        switch period.kind {
        case .week:
            days = Array(1...max(dayCount, 1))
        case .month:
            days = Array(stride(from: 1, through: dayCount, by: 7))
        case .year:
            days = (0..<4).compactMap {
                period.calendar.date(byAdding: .month, value: $0 * 3, to: period.start).flatMap(period.dayIndex(of:))
            }
        }
        axisDays = days
        axisLabels = Dictionary(uniqueKeysWithValues: days.map { day in
            let date = Self.date(forDay: day, in: period)
            let label = switch period.kind {
            case .week: date.formatted(.dateTime.weekday(.abbreviated))
            case .month: date.formatted(.dateTime.day())
            case .year: date.formatted(.dateTime.month(.abbreviated))
            }
            return (day, label)
        })
    }

    var body: some View {
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
                        ChartDayCallout(date: date(forDay: day),
                                        current: amount(in: summary.cumulativeSpend, day: day),
                                        previous: amount(in: summary.previousCumulativeSpend, day: day))
                    }
            }
        }
        .chartLegend(.hidden)
        .chartXScale(domain: 1...max(summary.period.dayCount, 2))
        .chartPlotStyle { $0.clipped() }
        .chartXSelection(value: $selectedDay)
        .chartXAxis {
            AxisMarks(values: axisDays) { value in
                AxisGridLine()
                AxisValueLabel(anchor: .top) {
                    if let day = value.as(Int.self), let label = axisLabels[day] {
                        Text(label)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel(anchor: .trailing) {
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
    private var selection: Int? {
        selectedDay.map { min(max($0, 1), summary.period.dayCount) }
    }

    private func amount(in points: [CumulativePoint], day: Int) -> Double? {
        points.first { $0.day == day }?.amount
    }

    private func date(forDay day: Int) -> Date {
        Self.date(forDay: day, in: summary.period)
    }

    private static func date(forDay day: Int, in period: Period) -> Date {
        let calendar = period.calendar
        return calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: period.start))
            ?? period.start
    }

    private var accessibilitySummary: String {
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

// MARK: - ChartDayCallout

private struct ChartDayCallout: View {
    @Environment(\.currencyCode) private var currencyCode
    let date: Date
    let current: Double?
    let previous: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            Text(date, format: .dateTime.day().month(.abbreviated))
                .font(.caption.bold())
            if let current {
                Text("Spent \(current.formattedMoney(code: currencyCode))")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            if let previous {
                Text("Previous \(previous.formattedMoney(code: currencyCode))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(MUSpacer.size03)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: MURadius.small))
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
