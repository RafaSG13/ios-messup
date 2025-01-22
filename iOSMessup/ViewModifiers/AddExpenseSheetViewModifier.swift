//
//  AddExpenseSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

struct AddExpenseSheetModifier: ViewModifier {
    @Binding var shouldPresentAddExpense: Bool
    @Binding var expenses: [Expense]

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $shouldPresentAddExpense, onDismiss: {
                shouldPresentAddExpense = false // Reset to false
            }) {
                AddExpenseViewModal(expenses: $expenses)
            }
    }
}

extension View {
    func addExpenseSheet(isPresented: Binding<Bool>, expenses: Binding<[Expense]>) -> some View {
        self.modifier(
            AddExpenseSheetModifier(
                shouldPresentAddExpense: isPresented,
                expenses: expenses
            )
        )
    }
}
