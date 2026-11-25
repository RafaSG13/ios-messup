//
//  IncomeCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - IncomeCellView

/// Plain row content: the enclosing `List` provides the surface.
struct IncomeCellView: View {
    @Environment(\.currencyCode) private var currencyCode
    let income: Income

    var body: some View {
        MUTransactionRow(systemImage: income.source.icon,
                         tint: income.source.color,
                         title: Text(income.concept),
                         subtitle: Text(income.source.rawValue),
                         amount: Text(income.amount.formattedSignedMoney(code: currencyCode)),
                         detail: Text(income.date, format: .dateTime.day().month(.abbreviated).year()))
    }
}

// MARK: - Previews

#Preview("Regular") {
    List(Income.mockArray.sorted().reversed()) { income in
        IncomeCellView(income: income)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Income.mockArray) { income in
        IncomeCellView(income: income)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
