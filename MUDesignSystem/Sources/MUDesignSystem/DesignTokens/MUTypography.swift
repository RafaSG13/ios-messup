//
//  MUTypography.swift
//  MUDesignSystem
//

import SwiftUI

public enum MUTypography {
    /// Hero figure of a card: spent, balance, goal percentage.
    public static let heroAmount = Font.system(.largeTitle, design: .rounded, weight: .bold).monospacedDigit()
    /// Amounts in list rows and stat tiles.
    public static let rowAmount = Font.system(.headline, design: .rounded).monospacedDigit()
    /// Small amounts in breakdown lines.
    public static let compactAmount = Font.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit()
}
