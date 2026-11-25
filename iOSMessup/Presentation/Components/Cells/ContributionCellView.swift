//
//  ContributionCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

/// Plain row content: the enclosing `List` provides the surface.
struct ContributionCellView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconSize: CGFloat = 40
    let contribution: Contribution

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size03))

        layout {
            MUIconTile(systemImage: "target", tint: .accentColor, size: iconSize)

            VStack(alignment: .leading) {
                if contribution.note.isEmpty {
                    Text("Contribution")
                        .font(.headline)
                } else {
                    Text(contribution.note)
                        .font(.headline)
                }
            }
            .frame(maxWidth: isAccessibilitySize ? nil : .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(contribution.amount.formattedMoney(code: currencyCode))
                    .font(MUTypography.rowAmount)
                Text(contribution.date, format: .dateTime.day().month(.abbreviated).year())
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
    List(Contribution.mockArray.sorted().reversed()) { contribution in
        ContributionCellView(contribution: contribution)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Contribution.mockArray) { contribution in
        ContributionCellView(contribution: contribution)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
