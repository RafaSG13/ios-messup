//
//  ExpenseSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

//MARK: - AddExpenseSheetModifier

struct AddExpenseSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: ((_ expense: Expense) async throws -> Void)?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                AddExpenseViewModal(onSubmit: onSubmit)
            }
    }
}

extension View {
    func addExpenseSheet(isPresented: Binding<Bool>, onSubmit: ((_ expense: Expense) async throws -> Void)?) -> some View {
        self.modifier(AddExpenseSheetModifier(isPresented: isPresented,
                                              onSubmit: onSubmit))
    }
}

//MARK: - EditExpenseSheetModifier

struct EditExpenseSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedItem: Expense?
    var onSubmit: (_ expense: Expense) async throws -> Void

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
    }
}


extension View {
    func editExpenseSheet(isPresented: Binding<Bool>, selectedItem: Binding<Expense?>, onSubmit: @escaping (_ expense: Expense) async throws -> Void) -> some View {
        self.modifier(EditExpenseSheetModifier(isPresented: isPresented,
                                               selectedItem: selectedItem,
                                               onSubmit: onSubmit))
    }
}
