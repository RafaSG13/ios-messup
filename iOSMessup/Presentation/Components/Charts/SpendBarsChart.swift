//
//  SpendBarsChart.swift
//  iOSMessup
//

import Charts
import SwiftUI

// MARK: - SpendBarsChart

/// Compact bars of what was spent per day (or per month for a year), without axes. The bar of the day in progress
/// is solid and the rest are softer, so the shape of the period reads at a glance. Meant to live inside a card.
struct SpendBarsChart: View {
    let bars: [SpendBar]
    let currentBar: Int?

    private enum ViewTraits {
        static let barWidthRatio = 0.7
        static let softOpacity = 0.45
        static let barRadius: CGFloat = 2
    }

    var body: some View {
        Chart(bars) { bar in
            BarMark(x: .value("Day", String(bar.index)),
                    y: .value("Spent", bar.amount),
                    width: .ratio(ViewTraits.barWidthRatio))
                .foregroundStyle(Color.accentColor.opacity(bar.index == currentBar ? 1 : ViewTraits.softOpacity))
                .cornerRadius(ViewTraits.barRadius)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Month") {
    SpendBarsChart(bars: (1...30).map { SpendBar(index: $0, amount: Double(($0 * 37) % 90)) }, currentBar: 22)
        .frame(height: 72)
        .padding()
}

#Preview("Year") {
    SpendBarsChart(bars: (1...12).map { SpendBar(index: $0, amount: Double(($0 * 53) % 400)) }, currentBar: 11)
        .frame(height: 72)
        .padding()
}
