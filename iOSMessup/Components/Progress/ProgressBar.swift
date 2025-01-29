//
//  ProgressBar.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

struct ProgressBar: View {
    var progress: Double
    var barColor: LinearGradient = .init(colors: [.gray.opacity(0.3), .gray.opacity(0.3)],
                                         startPoint: .leading,
                                         endPoint: .trailing)
    var progressColor: LinearGradient = .init(colors: [.green, .green],
                                              startPoint: .leading,
                                              endPoint: .trailing)
    var cornerRadius: CGFloat = 5
    var barHeight: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: barHeight)
                    .foregroundStyle(barColor)
                    .cornerRadius(cornerRadius)

                Rectangle()
                    .frame(width: CGFloat(progress) * geometry.size.width, height: barHeight)
                    .foregroundStyle(progressColor)
                    .cornerRadius(cornerRadius)
            }
        }
        .frame(height: barHeight)
    }
}
