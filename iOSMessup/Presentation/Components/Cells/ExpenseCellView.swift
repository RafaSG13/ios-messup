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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.currencyCode) private var currencyCode
    @ScaledMetric private var iconSize: CGFloat = 40
    let expense: Expense

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size03))

        layout {
            MUIconTile(systemImage: expense.category.icon, tint: expense.category.color, size: iconSize)

            VStack(alignment: .leading) {
                Text(expense.name)
                    .font(.headline)
                Text(expense.paymentMethod.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(expense.amount.formattedMoney(code: currencyCode))
                    .font(MUTypography.rowAmount)
                Text(expense.date, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: iconSize, alignment: .leading)
        .accessibilityElement(children: .combine)
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
