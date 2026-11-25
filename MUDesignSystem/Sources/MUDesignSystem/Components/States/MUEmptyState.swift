//
//  MUEmptyState.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - MUEmptyState

/// Empty state with a single prominent call to action.
public struct MUEmptyState: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let description: LocalizedStringKey
    private let actionTitle: LocalizedStringKey
    private let action: () -> Void

    public init(_ title: LocalizedStringKey,
                systemImage: String,
                description: LocalizedStringKey,
                actionTitle: LocalizedStringKey,
                action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview {
    MUEmptyState("No transactions",
                 systemImage: "creditcard",
                 description: "Add your first expense to see it here.",
                 actionTitle: "Add expense") {}
}
