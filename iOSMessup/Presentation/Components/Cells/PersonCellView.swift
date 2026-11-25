//
//  PersonCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - PersonCellView

/// Plain row content: the enclosing `List` provides the surface.
struct PersonCellView: View {
    @Environment(\.currencyCode) private var currencyCode
    let item: PersonBalance

    var body: some View {
        MUTransactionRow(systemImage: "person.fill",
                         tint: .accentColor,
                         title: Text(item.person.name),
                         subtitle: stateText,
                         amount: amountText,
                         detail: item.lastActivity.map { Text($0, format: .dateTime.day().month(.abbreviated).year()) }
                             ?? Text("No activity"))
    }

    private var stateText: Text {
        switch item.state {
        case .owesMe: Text("Owes you")
        case .iOwe: Text("You owe")
        case .settled: Text("Settled up")
        }
    }

    private var amountText: Text {
        switch item.state {
        case .owesMe, .iOwe: Text(item.balance.formattedSignedMoney(code: currencyCode))
        case .settled: Text(0.0.formattedMoney(code: currencyCode))
        }
    }
}

// MARK: - Previews

#Preview("Regular") {
    List(DebtSummary(people: Person.mockArray, entries: DebtEntry.mockArray).balances) { item in
        PersonCellView(item: item)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(DebtSummary(people: Person.mockArray, entries: DebtEntry.mockArray).balances) { item in
        PersonCellView(item: item)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
