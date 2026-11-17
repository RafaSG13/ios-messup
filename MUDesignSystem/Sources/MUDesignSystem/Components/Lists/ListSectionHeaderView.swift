//
//  ListSectionHeaderView.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI

/// Section title with a "view all" link that pushes `value` onto the enclosing `NavigationStack`.
/// The caller must provide a matching `navigationDestination(for:)`.
public struct ListSectionHeaderView<Value: Hashable>: View {
    var sectionTitle: LocalizedStringKey
    var actionTitle: LocalizedStringKey
    var value: Value

    public init(sectionTitle: LocalizedStringKey,
                actionTitle: LocalizedStringKey,
                value: Value) {
        self.sectionTitle = sectionTitle
        self.actionTitle = actionTitle
        self.value = value
    }

    public var body: some View {
        HStack {
            Text(sectionTitle)
                .font(.title2)
                .bold()
            Spacer()
            NavigationLink(value: value) {
                Text(actionTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListSectionHeaderView(sectionTitle: "Transactions", actionTitle: "View all", value: 0)
            .padding()
            .navigationDestination(for: Int.self) { Text("\($0)") }
    }
}
