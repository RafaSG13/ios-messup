//
//  DebtSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI

// MARK: - DebtEntrySheetModifier

struct DebtEntrySheetModifier: ViewModifier {
    @Binding var mode: DebtEntryFormView.Mode?
    var onSubmit: (DebtEntry) async throws -> Void

    func body(content: Content) -> some View {
        content
            .sheet(item: $mode) { mode in
                DebtEntryFormView(mode: mode, onSubmit: onSubmit)
            }
    }
}

extension View {
    /// Presents the debt entry form (add or edit) while `mode` is non-nil and clears it on dismiss.
    func debtEntrySheet(mode: Binding<DebtEntryFormView.Mode?>, onSubmit: @escaping (DebtEntry) async throws -> Void) -> some View {
        modifier(DebtEntrySheetModifier(mode: mode, onSubmit: onSubmit))
    }
}

// MARK: - DeletePersonDialogModifier

/// The one confirmation for deleting a person (list swipe and detail menu): it also deletes their history.
struct DeletePersonDialogModifier: ViewModifier {
    @Environment(\.debtsService) private var debtsService
    @Binding var person: Person?
    @Binding var error: (any Error)?
    var onDeleted: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Delete \(person?.name ?? "")?",
                                isPresented: isPresented,
                                titleVisibility: .visible,
                                presenting: person) { person in
                Button("Delete", role: .destructive) { delete(person) }
            } message: { person in
                Text("Their \(debtsService.entries(for: person).count) debts and payments are deleted too.")
            }
    }

    private var isPresented: Binding<Bool> {
        Binding(get: { person != nil },
                set: { if !$0 { person = nil } })
    }

    private func delete(_ person: Person) {
        Task {
            do {
                try await debtsService.deletePerson(person)
                onDeleted()
            } catch {
                self.error = error
            }
        }
    }
}

extension View {
    /// Asks before deleting `person` (and their history); `onDeleted` runs after a successful delete.
    func deletePersonDialog(person: Binding<Person?>,
                            error: Binding<(any Error)?>,
                            onDeleted: @escaping () -> Void = {}) -> some View {
        modifier(DeletePersonDialogModifier(person: person, error: error, onDeleted: onDeleted))
    }
}
