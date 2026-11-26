//
//  MUMetricLabel.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUMetricLabel

/// Caption with an icon above a compact amount (income, expenses, saved).
public struct MUMetricLabel: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let title: LocalizedStringKey
    private let systemImage: String
    private let value: String

    public init(_ title: LocalizedStringKey, systemImage: String, value: String) {
        self.title = title
        self.systemImage = systemImage
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size01) {
            HStack(spacing: MUSpacer.size02) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            Text(value)
                .font(MUTypography.compactAmount)
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    MUAdaptiveStack(alignment: .top) {
        MUMetricLabel("Income", systemImage: "arrow.down.circle.fill", value: "+2,5K €")
        MUMetricLabel("Expenses", systemImage: "creditcard.fill", value: "−1,4K €")
        MUMetricLabel("Saved", systemImage: "banknote.fill", value: "−300 €")
    }
    .padding()
}
