//
//  DepositCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI
import MUDesignSystem

/// Plain row content: the enclosing `List` provides the surface.
struct DepositCellView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconSize: CGFloat = 40
    let deposit: Deposit

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size03))

        layout {
            Image(systemName: deposit.foundingSource.icon)
                .symbolVariant(.fill)
                .foregroundStyle(deposit.foundingSource.color)
                .frame(width: iconSize, height: iconSize)
                .background(deposit.foundingSource.color.opacity(0.15), in: .rect(cornerRadius: MURadius.small))
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(deposit.concept)
                    .font(.headline)
                Text(deposit.foundingSource.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: isAccessibilitySize ? nil : .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(deposit.amount.formattedMoney(code: currencyCode))
                    .bold()
                    .foregroundStyle(.green)
                Text(deposit.date, format: .dateTime.day().month(.abbreviated).year())
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
    List(Deposit.mockArray.sorted().reversed()) { deposit in
        DepositCellView(deposit: deposit)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Deposit.mockArray) { deposit in
        DepositCellView(deposit: deposit)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
