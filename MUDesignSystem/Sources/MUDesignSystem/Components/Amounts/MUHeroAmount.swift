//
//  MUHeroAmount.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUHeroAmount

/// Hero figure of a card (spent, balance, goal percentage) that animates when `value` changes.
public struct MUHeroAmount: View {
    private let text: String
    private let value: Double
    private let tint: Color

    public init(_ text: String, value: Double, tint: Color = .primary) {
        self.text = text
        self.value = value
        self.tint = tint
    }

    public var body: some View {
        Text(text)
            .font(MUTypography.heroAmount)
            .foregroundStyle(tint)
            .contentTransition(.numericText(value: value))
            .animation(.snappy, value: value)
            .minimumScaleFactor(0.6)
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading) {
        MUHeroAmount("1.436,02 €", value: 1436.02)
        MUHeroAmount("−120,00 €", value: -120, tint: .red)
        MUHeroAmount("65 %", value: 0.65, tint: .accentColor)
    }
    .padding()
}
