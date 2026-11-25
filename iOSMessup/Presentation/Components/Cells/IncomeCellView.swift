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
            MUIconTile(systemImage: income.source.icon, tint: income.source.color, size: iconSize)

            VStack(alignment: .leading) {
                Text(income.concept)
                    .font(.headline)
                Text(income.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: isAccessibilitySize ? nil : .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(income.amount.formattedSignedMoney(code: currencyCode))
                    .font(MUTypography.rowAmount)
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
