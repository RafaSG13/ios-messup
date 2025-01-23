//
//  EditExpenseSheetModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

struct EditExpenseSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedItem: Expense?
    var onSubmit: ((_ expense: Expense) -> Void)?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: resetSelectedItem) {
                if let selectedItem {
                    EditExpenseModalView(expense: selectedItem, onSubmit: onSubmit)
                } else {
                    Text("No expense selected.")
                }
            }
    }

    private func resetSelectedItem() {
        selectedItem = nil
        isPresented = false
    }
}


extension View {
    func editExpenseSheet(isPresented: Binding<Bool>, selectedItem: Binding<Expense?>, onSubmit: ((_ expense: Expense) -> Void)?) -> some View {
        self.modifier(EditExpenseSheetModifier(isPresented: isPresented,
                                               selectedItem: selectedItem,
                                               onSubmit: onSubmit))
    }
}
