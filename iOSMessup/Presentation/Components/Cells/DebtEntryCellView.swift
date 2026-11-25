//
//  DebtEntryCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - DebtEntryCellView

/// Plain row content: the enclosing `List` provides the surface.
struct DebtEntryCellView: View {
    @Environment(\.currencyCode) private var currencyCode
    let entry: DebtEntry

    var body: some View {
        MUTransactionRow(systemImage: entry.kind.icon,
                         tint: entry.kind.tint,
                         title: Text(entry.kind.title),
                         subtitle: entry.note.isEmpty ? nil : Text(entry.note),
                         amount: Text(entry.amount.formattedMoney(code: currencyCode)),
                         detail: Text(entry.date, format: .dateTime.day().month(.abbreviated).year()))
    }
}

// MARK: - Previews

#Preview("Regular") {
    List(DebtEntry.mockArray.sorted().reversed()) { entry in
        DebtEntryCellView(entry: entry)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(DebtEntry.mockArray) { entry in
        DebtEntryCellView(entry: entry)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
