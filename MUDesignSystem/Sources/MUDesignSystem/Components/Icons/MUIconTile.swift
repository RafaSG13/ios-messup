//
//  MUIconTile.swift
//  MUDesignSystem
//

import SwiftUI

/// Rounded square with a tinted glyph; the single icon treatment used by every list row and card.
public struct MUIconTile: View {
    private let systemImage: String
    private let tint: Color
    private let size: CGFloat

    public init(systemImage: String, tint: Color, size: CGFloat = 40) {
        self.systemImage = systemImage
        self.tint = tint
        self.size = size
    }

    public var body: some View {
        Image(systemName: systemImage)
            .symbolVariant(.fill)
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.15), in: .rect(cornerRadius: size * 0.25, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: MUSpacer.size04) {
        MUIconTile(systemImage: "cart", tint: .orange)
        MUIconTile(systemImage: "target", tint: .accentColor)
        MUIconTile(systemImage: "heart", tint: .red, size: 56)
    }
    .padding()
}
