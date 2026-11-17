//
//  ProgressBar.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

public struct ProgressBar: View {
    var progress: Double
    var barColor: LinearGradient
    var progressColor: LinearGradient
    var cornerRadius: CGFloat
    var barHeight: CGFloat

    public init(progress: Double,
                barColor: LinearGradient = .init(colors: [.gray.opacity(0.3), .gray.opacity(0.3)],
                                                 startPoint: .leading,
                                                 endPoint: .trailing),
                progressColor: LinearGradient = .init(colors: [.green, .green],
                                                      startPoint: .leading,
                                                      endPoint: .trailing),
                cornerRadius: CGFloat = 5,
                barHeight: CGFloat = 10) {
        self.progress = progress
        self.barColor = barColor
        self.progressColor = progressColor
        self.cornerRadius = cornerRadius
        self.barHeight = barHeight
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: barHeight)
                    .foregroundStyle(barColor)
                    .clipShape(.rect(cornerRadius: cornerRadius))

                Rectangle()
                    .frame(width: CGFloat(progress) * geometry.size.width, height: barHeight)
                    .foregroundStyle(progressColor)
                    .clipShape(.rect(cornerRadius: cornerRadius))
            }
        }
        .frame(height: barHeight)
    }
}

#Preview {
    ProgressBar(progress: 0.6)
        .padding()
}
