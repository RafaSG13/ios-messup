//
//  ContributionCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - ContributionCellView

/// Plain row content: the enclosing `List` provides the surface.
struct ContributionCellView: View {
    @Environment(\.currencyCode) private var currencyCode
    let contribution: Contribution

    var body: some View {
        MUTransactionRow(systemImage: "target",
                         tint: .accentColor,
                         title: contribution.note.isEmpty ? Text("Contribution") : Text(contribution.note),
                         amount: Text(contribution.amount.formattedMoney(code: currencyCode)),
                         detail: Text(contribution.date, format: .dateTime.day().month(.abbreviated).year()))
    }
}

// MARK: - Previews

#Preview("Regular") {
    List(Contribution.mockArray.sorted().reversed()) { contribution in
        ContributionCellView(contribution: contribution)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Contribution.mockArray) { contribution in
        ContributionCellView(contribution: contribution)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
