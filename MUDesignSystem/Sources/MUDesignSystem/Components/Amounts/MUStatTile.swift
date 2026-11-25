//
//  MUStatTile.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUStatTile

/// Small tile with an amount and its caption, used in rows of three stats.
public struct MUStatTile: View {
    private let title: LocalizedStringKey
    private let value: String

    public init(_ title: LocalizedStringKey, value: String) {
        self.title = title
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(MUTypography.rowAmount)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(MUSpacer.size03)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: MURadius.small))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    MUAdaptiveStack {
        MUStatTile("Earned", value: "1,2K €")
        MUStatTile("Left", value: "800 €")
        MUStatTile("Required", value: "2K €")
    }
    .padding()
}
