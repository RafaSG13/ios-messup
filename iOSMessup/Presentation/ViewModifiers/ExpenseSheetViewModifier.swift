//
//  ExpenseSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import SwiftUI

// MARK: - AddExpenseSheetModifier

struct AddExpenseSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: (_ expense: Expense) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ExpenseFormView(mode: .add, onSubmit: onSubmit)
            }
    }
}

// MARK: - EditExpenseSheetModifier

struct EditExpenseSheetModifier: ViewModifier {
    @Binding var item: Expense?
    var onSubmit: (_ expense: Expense) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { expense in
                ExpenseFormView(mode: .edit(expense), onSubmit: onSubmit)
            }
    }
}

// MARK: - View API

extension View {
    func addExpenseSheet(isPresented: Binding<Bool>, onSubmit: @escaping (_ expense: Expense) async throws -> Void) -> some View {
        modifier(AddExpenseSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }

    func editExpenseSheet(item: Binding<Expense?>, onSubmit: @escaping (_ expense: Expense) async throws -> Void) -> some View {
        modifier(EditExpenseSheetModifier(item: item, onSubmit: onSubmit))
    }
}
