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
    let expense: Expense

    private enum ViewTraits {
        static let imageSize: CGFloat = 40
        static let imageInternalPadding: CGFloat = 5
        static let spacing: CGFloat = 10
        static let minHeight: CGFloat = 44
    }

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: ViewTraits.spacing))
            : AnyLayout(HStackLayout(spacing: ViewTraits.spacing))

        layout {
            Image(systemName: expense.category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .padding(ViewTraits.imageInternalPadding)
                .background(expense.category.color, in: .rect(cornerRadius: MURadius.small))
                .foregroundStyle(.background)

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
                    .font(.headline)
                Text(expense.date, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: ViewTraits.minHeight, alignment: .leading)
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
