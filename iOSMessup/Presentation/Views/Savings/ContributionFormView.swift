//
//  ContributionFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

struct ContributionFormView: View {
    enum Mode {
        case add
        case edit(Contribution)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var amount: Double
    @State private var date: Date
    @State private var note: String
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (Contribution) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (Contribution) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add:
            _amount = State(initialValue: 0)
            _date = State(initialValue: Date())
            _note = State(initialValue: "")
        case .edit(let contribution):
            _amount = State(initialValue: contribution.amount)
            _date = State(initialValue: contribution.date)
            _note = State(initialValue: contribution.note)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm, action: save)
                        .disabled(isSaving || amount <= 0)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { hideKeyboard() }
                    }
                }
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension ContributionFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .add: "Add contribution"
        case .edit: "Edit contribution"
        }
    }

    /// Keeps the original `id` when editing (the services ignore unknown ids).
    var currentContribution: Contribution {
        let id: String
        switch mode {
        case .add: id = UUID().uuidString
        case .edit(let original): id = original.id
        }
        return Contribution(id: id, amount: amount, date: date, note: note)
    }

    func save() {
        isSaving = true
        let contribution = currentContribution
        Task {
            do {
                try await onSubmit(contribution)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Add") {
    ContributionFormView(mode: .add) { _ in }
}

#Preview("Edit") {
    ContributionFormView(mode: .edit(Contribution.mock)) { _ in }
}

#Preview("Failing submit") {
    struct SubmitError: LocalizedError {
        var errorDescription: String? { "The contribution could not be saved." }
    }

    return ContributionFormView(mode: .edit(Contribution.mock)) { _ in throw SubmitError() }
}
