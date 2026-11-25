//
//  ClearListRow.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - Clear List Row ViewModifier

/// Row with no background and no separator, for cards and empty states placed in a `List`.
/// `nil` insets keep the system default; `EdgeInsets()` gives a full-width card row.
public struct ClearListRow: ViewModifier {
    let insets: EdgeInsets?

    public init(insets: EdgeInsets?) {
        self.insets = insets
    }

    public func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowInsets(insets)
            .listRowSeparator(.hidden)
    }
}

public extension View {
    func clearListRow(insets: EdgeInsets? = nil) -> some View {
        modifier(ClearListRow(insets: insets))
    }
}

// MARK: - Preview

#Preview {
    List {
        Text("Card").clearListRow(insets: EdgeInsets())
        Text("Row")
    }
    .listStyle(.insetGrouped)
}
