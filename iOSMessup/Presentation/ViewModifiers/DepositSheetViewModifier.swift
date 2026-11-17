//
//  DepositSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI

// MARK: - AddDepositSheetModifier

struct AddDepositSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: (Deposit) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                DepositFormView(mode: .add, onSubmit: onSubmit)
            }
    }
}

extension View {
    func addDepositSheet(isPresented: Binding<Bool>, onSubmit: @escaping (Deposit) async throws -> Void) -> some View {
        modifier(AddDepositSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }
}

// MARK: - EditDepositSheetModifier

struct EditDepositSheetModifier: ViewModifier {
    @Binding var deposit: Deposit?
    var onSubmit: (Deposit) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $deposit) { deposit in
                DepositFormView(mode: .edit(deposit), onSubmit: onSubmit)
            }
    }
}

extension View {
    /// Presents the edit form while `deposit` is non-nil and clears it on dismiss.
    func editDepositSheet(deposit: Binding<Deposit?>, onSubmit: @escaping (Deposit) async throws -> Void) -> some View {
        modifier(EditDepositSheetModifier(deposit: deposit, onSubmit: onSubmit))
    }
}

// MARK: - SavingGoalSheetModifier

struct SavingGoalSheetModifier: ViewModifier {
    @Binding var mode: SavingGoalFormView.Mode?
    var onSubmit: (SavingGoal) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $mode) { mode in
                SavingGoalFormView(mode: mode, onSubmit: onSubmit)
            }
    }
}

extension View {
    /// Presents the saving goal form (create or edit) while `mode` is non-nil and clears it on dismiss.
    func savingGoalSheet(mode: Binding<SavingGoalFormView.Mode?>, onSubmit: @escaping (SavingGoal) async throws -> Void) -> some View {
        modifier(SavingGoalSheetModifier(mode: mode, onSubmit: onSubmit))
    }
}
