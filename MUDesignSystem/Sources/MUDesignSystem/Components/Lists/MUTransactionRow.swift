//
//  MUTransactionRow.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUTransactionRow

/// Plain row content shared by expense, income and contribution cells; the enclosing `List` provides the surface.
public struct MUTransactionRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var iconSize: CGFloat = 40
    private let systemImage: String
    private let tint: Color
    private let title: Text
    private let subtitle: Text?
    private let amount: Text
    private let detail: Text

    public init(systemImage: String,
                tint: Color,
                title: Text,
                subtitle: Text? = nil,
                amount: Text,
                detail: Text) {
        self.systemImage = systemImage
        self.tint = tint
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.detail = detail
    }

    public var body: some View {
        let isAX = dynamicTypeSize.isAccessibilitySize
        MUAdaptiveStack {
            MUIconTile(systemImage: systemImage, tint: tint, size: iconSize)

            VStack(alignment: .leading) {
                title
                    .font(.headline)
                if let subtitle {
                    subtitle
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: isAX ? nil : .infinity, alignment: .leading)

            VStack(alignment: isAX ? .leading : .trailing) {
                amount
                    .font(MUTypography.rowAmount)
                detail
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Regular") {
    List {
        MUTransactionRow(systemImage: "cart",
                         tint: .orange,
                         title: Text("Groceries"),
                         subtitle: Text("Card"),
                         amount: Text("42,50 €"),
                         detail: Text("12 Nov"))
        MUTransactionRow(systemImage: "target",
                         tint: .accentColor,
                         title: Text("Contribution"),
                         amount: Text("100,00 €"),
                         detail: Text("3 Nov 2026"))
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List {
        MUTransactionRow(systemImage: "cart",
                         tint: .orange,
                         title: Text("Groceries"),
                         subtitle: Text("Card"),
                         amount: Text("42,50 €"),
                         detail: Text("12 Nov"))
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
