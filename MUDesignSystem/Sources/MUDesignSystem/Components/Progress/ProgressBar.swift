//
//  ProgressBar.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

/// Horizontal capsule progress indicator. `progress` is clamped to `0...1`.
public struct ProgressBar: View {
    var progress: Double
    var tint: Color
    var barHeight: CGFloat

    public init(progress: Double,
                tint: Color = .accentColor,
                barHeight: CGFloat = MUSpacer.size03) {
        self.progress = progress
        self.tint = tint
        self.barHeight = barHeight
    }

    public var body: some View {
        Capsule()
            .fill(.quaternary)
            .frame(height: barHeight)
            .overlay(alignment: .leading) {
                GeometryReader { geometry in
                    Capsule()
                        .fill(tint)
                        .frame(width: geometry.size.width * min(max(progress, 0), 1))
                }
            }
            .animation(.easeInOut, value: progress)
            .accessibilityElement()
            .accessibilityLabel("Progress")
            .accessibilityValue(Text(min(max(progress, 0), 1), format: .percent.precision(.fractionLength(0))))
    }
}

#Preview {
    VStack(spacing: MUSpacer.size04) {
        ProgressBar(progress: 0.6)
        ProgressBar(progress: 1, tint: .blue)
        ProgressBar(progress: 0)
    }
    .padding()
}
