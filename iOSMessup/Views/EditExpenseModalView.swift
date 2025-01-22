//
//  EditExpenseModalView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct EditExpenseModalView: View {
    @Binding var expense: Expense
    var body: some View {
        VStack {
            Text(expense.name)
            Text(expense.amount.toMoneyString())
        }
    }
}

#Preview {
    EditExpenseModalView(expense: .constant(.mock))
}
