//
//  RainbowProgressView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/6/25.
//

import SwiftUI

struct MULoadingHudModifier: ViewModifier {
    @Binding var isLoading: Bool
    var text: String = "Loading"

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                Color.mint
                    .opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2, anchor: .center)
                        .tint(.white)
                    Text(text)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                }
            }
        }
    }
}


#Preview {
    AllExpensesView()
        .loadingHUD(isLoading: true)
}


extension View {
    func loadingHUD(isLoading: Bool) -> some View {
        modifier(MULoadingHudModifier(isLoading: .constant(isLoading)))
    }
}
