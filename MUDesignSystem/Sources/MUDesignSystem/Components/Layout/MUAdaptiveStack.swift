//
//  MUAdaptiveStack.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUAdaptiveStack

/// `HStack` normally, leading-aligned `VStack` at accessibility type sizes.
public struct MUAdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let alignment: VerticalAlignment
    private let spacing: CGFloat
    private let content: Content

    public init(alignment: VerticalAlignment = .center,
                spacing: CGFloat = MUSpacer.size03,
                @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(alignment: alignment, spacing: spacing))
        layout { content }
    }
}

// MARK: - Preview

#Preview("Regular") {
    MUAdaptiveStack {
        Text("One")
        Text("Two")
        Text("Three")
    }
    .padding()
}

#Preview("Accessibility size") {
    MUAdaptiveStack {
        Text("One")
        Text("Two")
        Text("Three")
    }
    .padding()
    .dynamicTypeSize(.accessibility3)
}
