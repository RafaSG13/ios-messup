//
//  SavingsSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

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

// MARK: - AddContributionSheetModifier

struct AddContributionSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: (Contribution) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ContributionFormView(mode: .add, onSubmit: onSubmit)
            }
    }
}

extension View {
    func addContributionSheet(isPresented: Binding<Bool>, onSubmit: @escaping (Contribution) async throws -> Void) -> some View {
        modifier(AddContributionSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }
}

// MARK: - EditContributionSheetModifier

struct EditContributionSheetModifier: ViewModifier {
    @Binding var contribution: Contribution?
    var onSubmit: (Contribution) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $contribution) { contribution in
                ContributionFormView(mode: .edit(contribution), onSubmit: onSubmit)
            }
    }
}

extension View {
    /// Presents the edit form while `contribution` is non-nil and clears it on dismiss.
    func editContributionSheet(contribution: Binding<Contribution?>, onSubmit: @escaping (Contribution) async throws -> Void) -> some View {
        modifier(EditContributionSheetModifier(contribution: contribution, onSubmit: onSubmit))
    }
}
