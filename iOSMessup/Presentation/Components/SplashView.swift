//
//  SplashView.swift
//  iOSMessup
//

import SwiftUI

// MARK: - SplashView

/// Picks up exactly where the system launch screen leaves off (mint background, centered logo) and, once the data
/// has loaded, lets the logo swell and fade while the background dissolves into the app. `onFinished` runs when the
/// animation is over, so the owner can remove the view.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let isFinished: Bool
    let onFinished: () -> Void
    @State private var isDismissing = false

    private enum ViewTraits {
        static let dismissScale = 1.6
        static let duration = 0.55
    }

    var body: some View {
        ZStack {
            Color("mintAccent")
                .opacity(isDismissing ? 0 : 1)
            Image("logoPNG")
                .scaleEffect(isDismissing && !reduceMotion ? ViewTraits.dismissScale : 1)
                .opacity(isDismissing ? 0 : 1)
                .accessibilityHidden(true)
        }
        .ignoresSafeArea()
        .allowsHitTesting(!isDismissing)
        .onChange(of: isFinished) { _, finished in
            guard finished else { return }
            withAnimation(.easeIn(duration: ViewTraits.duration), completionCriteria: .removed) {
                isDismissing = true
            } completion: {
                onFinished()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isFinished = false
    SplashView(isFinished: isFinished, onFinished: {})
        .task {
            try? await Task.sleep(for: .seconds(1))
            isFinished = true
        }
}
