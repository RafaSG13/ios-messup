//
//  TransactionCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct ExpenseCellView: View {
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
        HStack(spacing: ViewTraits.generalPadding) {
            Image(systemName: expense.category.icon)
                .resizable()
                .frame(width: ViewTraits.imageSize, height: ViewTraits.imageSize)
                .scaledToFill()
                .padding(ViewTraits.imageInternalPadding)
                .background(expense.category.color)
                .foregroundColor(.white)
                .clipShape(.rect(cornerRadius: ViewTraits.cornerRadius))

            VStack(alignment: .leading) {
                Text(expense.name)
                    .bold()
                    .font(.headline)
                Text(expense.paymentMethod.rawValue)
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(expense.amount.toMoneyString())
                    .bold()
                    .foregroundStyle(.green)
                Text(expense.date.formatted())
                    .font(.caption)
            }
        }
        .padding(ViewTraits.generalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: ViewTraits.cellHeight)
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

//MARK: - ExpenseCellView + SelectableCell

extension ExpenseCellView {
    func selectableCell(selectedItem: Binding<Expense?>, _ onTap: (() -> Void)? = nil) -> some View {
        self.modifier(SelectableCell(selectedItem: selectedItem, ownItem: self.expense, onTap: onTap))
    }
}
