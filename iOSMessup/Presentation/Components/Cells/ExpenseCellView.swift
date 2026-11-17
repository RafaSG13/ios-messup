//
//  ExpenseCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct ExpenseCellView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let expense: Expense

    private enum ViewTraits {
        static let imageSize: CGFloat = 40
        static let imageInternalPadding: CGFloat = 5
        static let generalPadding: CGFloat = 10
        static let backgroundColor: Color = .secondary.opacity(0.15)
        static let cornerRadius: CGFloat = 10
        static let generalSpacing: CGFloat = 10
        static let cellHeight: CGFloat = 70
    }

    var body: some View {
        let isAccessibilitySize = dynamicTypeSize.isAccessibilitySize
        let layout = isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: ViewTraits.generalPadding))
            : AnyLayout(HStackLayout(spacing: ViewTraits.generalPadding))

        layout {
            Image(systemName: expense.category.icon)
                .resizable()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .scaledToFill()
                .padding(ViewTraits.imageInternalPadding)
                .background(expense.category.color)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))

            VStack(alignment: .leading) {
                Text(expense.name)
                    .bold()
                    .font(.headline)
                Text(expense.paymentMethod.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: isAccessibilitySize ? .leading : .trailing) {
                Text(expense.amount.toMoneyString())
                    .bold()
                    .foregroundStyle(.green)
                Text(expense.date.formatted())
                    .font(.caption)
            }
        }
        .padding(ViewTraits.generalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: ViewTraits.cellHeight)
        .background(ViewTraits.backgroundColor)
        .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))
    }
}

//MARK: - Previews

#Preview {
    ScrollView {
        LazyVStack {
            ForEach(Expense.mockArray) { expense in
                ExpenseCellView(expense: expense)
            }
        }
    }
    .scrollIndicators(.hidden)
    .padding()
}
