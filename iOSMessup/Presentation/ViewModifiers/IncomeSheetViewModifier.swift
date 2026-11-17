//
//  IncomeSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI

// MARK: - AddIncomeSheetModifier

struct AddIncomeSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: (Income) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                IncomeFormView(mode: .add, onSubmit: onSubmit)
            }
    }
}

extension View {
    func addIncomeSheet(isPresented: Binding<Bool>, onSubmit: @escaping (Income) async throws -> Void) -> some View {
        modifier(AddIncomeSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }
}

// MARK: - EditIncomeSheetModifier

struct EditIncomeSheetModifier: ViewModifier {
    @Binding var income: Income?
    var onSubmit: (Income) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $income) { income in
                IncomeFormView(mode: .edit(income), onSubmit: onSubmit)
            }
    }
}

extension View {
    /// Presents the edit form while `income` is non-nil and clears it on dismiss.
    func editIncomeSheet(income: Binding<Income?>, onSubmit: @escaping (Income) async throws -> Void) -> some View {
        modifier(EditIncomeSheetModifier(income: income, onSubmit: onSubmit))
    }
}
