//
//  CircularSavingProgressView.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

public struct CircularSavingProgressView<Label: View>: View {
    var progress: CGFloat
    var lineWidth: CGFloat
    var progressColor: Color
    var backgroundColor: Color
    var label: () -> Label

    public init(progress: CGFloat = 0.25,
                lineWidth: CGFloat = 30,
                progressColor: Color = .pink,
                backgroundColor: Color = .pink.opacity(0.5),
                @ViewBuilder label: @escaping () -> Label) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.progressColor = progressColor
        self.backgroundColor = backgroundColor
        self.label = label
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(
                    backgroundColor,
                    lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            label()
        }.animation(.easeIn, value: progress)
    }
}

#Preview {
    CircularSavingProgressView {
        VStack {
            Text("45%")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.pink)
            Text("Required")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
    .frame(width: 200, height: 200)
}
