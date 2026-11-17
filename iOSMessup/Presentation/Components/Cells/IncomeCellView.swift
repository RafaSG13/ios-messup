//
//  IncomeCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI
import MUDesignSystem

/// Plain row content: the enclosing `List` provides the surface.
struct IncomeCellView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconSize: CGFloat = 40
    let income: Income

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size03))

        layout {
            Image(systemName: income.source.icon)
                .symbolVariant(.fill)
                .foregroundStyle(income.source.color)
                .frame(width: iconSize, height: iconSize)
                .background(income.source.color.opacity(0.15), in: .rect(cornerRadius: MURadius.small))
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(income.concept)
                    .font(.headline)
                Text(income.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: isAccessibilitySize ? nil : .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(income.amount.formattedMoney(code: currencyCode))
                    .bold()
                    .foregroundStyle(.green)
                Text(income.date, format: .dateTime.day().month(.abbreviated).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: iconSize, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#Preview("Regular") {
    List(Income.mockArray.sorted().reversed()) { income in
        IncomeCellView(income: income)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Income.mockArray) { income in
        IncomeCellView(income: income)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
