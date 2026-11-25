//
//  MUCard.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

/// A plain content surface with an optional title. Cards hold content (charts, summaries); they are never glass:
/// glass is reserved for navigation and controls.
public struct MUCard<Content: View>: View {
    private let title: LocalizedStringKey?
    private let content: Content

    public init(_ title: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size04) {
            if let title {
                Text(title)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }
            content
        }
        .padding(MUSpacer.size04)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: MURadius.large))
    }
}

#Preview {
    MUCard("Last 7 days") {
        Text("Content")
            .frame(height: 120)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
