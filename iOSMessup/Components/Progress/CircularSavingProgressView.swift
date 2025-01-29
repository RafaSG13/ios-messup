//
//  CircularSavingProgressView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

struct CircularSavingProgressView<Label: View>: View {
    //TODO: Check if progress should be a @State
    @State var progress: CGFloat = 0.25
    var lineWidth: CGFloat = 30
    var progressColor: Color = .pink
    var backgroundColor: Color = .pink.opacity(0.5)
    var label: () -> Label

    var body: some View {
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
