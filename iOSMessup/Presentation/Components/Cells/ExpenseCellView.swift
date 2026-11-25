//
//  ExpenseCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpenseCellView

/// Plain row content; the enclosing `List` provides the surface.
struct ExpenseCellView: View {
    @Environment(\.currencyCode) private var currencyCode
    let expense: Expense

    var body: some View {
        MUTransactionRow(systemImage: expense.category.icon,
                         tint: expense.category.color,
                         title: Text(expense.name),
                         subtitle: Text(expense.paymentMethod.rawValue),
                         amount: Text(expense.amount.formattedMoney(code: currencyCode)),
                         detail: Text(expense.date, format: .dateTime.day().month().hour().minute()))
    }
}

// MARK: - Previews

#Preview("Mock data") {
    List(Expense.mockArray) { expense in
        ExpenseCellView(expense: expense)
    }
    .listStyle(.insetGrouped)
}

#Preview("Accessibility size") {
    List(Expense.mockArray) { expense in
        ExpenseCellView(expense: expense)
    }
    .listStyle(.insetGrouped)
    .dynamicTypeSize(.accessibility3)
}
