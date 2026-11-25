//
//  DebtEntryFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI

struct DebtEntryFormView: View {
    enum Mode: Identifiable {
        case add(personID: String, kind: DebtEntryKind = .lent, amount: Double = 0)
        case edit(DebtEntry)

        var id: String {
            switch self {
            case .add(let personID, _, _): "add-\(personID)"
            case .edit(let entry): "edit-\(entry.id)"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var kind: DebtEntryKind
    @State private var amount: Double
    @State private var date: Date
    @State private var note: String
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (DebtEntry) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (DebtEntry) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add(_, let kind, let amount):
            _kind = State(initialValue: kind)
            _amount = State(initialValue: amount)
            _date = State(initialValue: Date())
            _note = State(initialValue: "")
        case .edit(let entry):
            _kind = State(initialValue: entry.kind)
            _amount = State(initialValue: entry.amount)
            _date = State(initialValue: entry.date)
            _note = State(initialValue: entry.note)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $kind) {
                        ForEach(DebtEntryKind.allCases) { kind in
                            Text(kind.title).tag(kind)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section {
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                } header: {
                    Text("Details")
                } footer: {
                    Text("Money you lend or pay back lowers your balance; money you borrow or get back raises it. If you already logged the full amount as an expense, log only your own share there.")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar(isSaveDisabled: isSaving || amount <= 0,
                            onCancel: { dismiss() },
                            onSave: save)
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension DebtEntryFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .add: "Add entry"
        case .edit: "Edit entry"
        }
    }

    /// Keeps the original `id` and `personID` when editing (the services ignore unknown ids).
    var currentEntry: DebtEntry {
        switch mode {
        case .add(let personID, _, _):
            DebtEntry(personID: personID, kind: kind, amount: amount, date: date, note: note)
        case .edit(let original):
            DebtEntry(id: original.id, personID: original.personID, kind: kind, amount: amount, date: date, note: note)
        }
    }

    func save() {
        isSaving = true
        let entry = currentEntry
        Task {
            do {
                try await onSubmit(entry)
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
    DebtEntryFormView(mode: .add(personID: Person.mock.id)) { _ in }
}

#Preview("Settle up") {
    DebtEntryFormView(mode: .add(personID: Person.mock.id, kind: .receivedPayment, amount: 45)) { _ in }
}

#Preview("Edit") {
    DebtEntryFormView(mode: .edit(DebtEntry.mock)) { _ in }
}

#Preview("Failing submit") {
    struct SubmitError: LocalizedError {
        var errorDescription: String? { "The entry could not be saved." }
    }

    return DebtEntryFormView(mode: .edit(DebtEntry.mock)) { _ in throw SubmitError() }
}
