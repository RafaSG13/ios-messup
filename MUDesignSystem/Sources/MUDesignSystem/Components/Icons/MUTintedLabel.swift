//
//  MUTintedLabel.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUTintedLabel

/// Picker/list option: text with a leading filled symbol in the item's color. Callers apply `.tag(...)`.
public struct MUTintedLabel: View {
    private let title: String
    private let systemImage: String
    private let tint: Color

    public init(_ title: String, systemImage: String, tint: Color) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .symbolVariant(.fill)
        }
    }
}

// MARK: - Preview

#Preview {
    Form {
        MUTintedLabel("Groceries", systemImage: "cart", tint: .orange)
        MUTintedLabel("Transport", systemImage: "bus", tint: .blue)
    }
}
