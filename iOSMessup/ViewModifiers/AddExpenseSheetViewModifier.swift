//
//  AddExpenseSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

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
