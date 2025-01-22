//
//  TransactionCellView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct ExpenseCellView: View {
    let expense: Expense

    var body: some View {
        HStack {
            Image(systemName: "cart.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .scaledToFill()
                .padding(5)
                .background(.white)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.trailing, 10)

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
        .padding(.vertical)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: 60)
        .background(.gray.opacity(0.2))
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    ExpenseCellView(expense: Expense.mock)
        .previewLayout(.sizeThatFits)
}
