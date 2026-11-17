//
//  DepositFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

struct DepositFormView: View {
    enum Mode {
        case add
        case edit(Deposit)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var concept: String
    @State private var amount: Double
    @State private var date: Date
    @State private var foundingSource: FoundingSource
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (Deposit) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (Deposit) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add:
            _concept = State(initialValue: "")
            _amount = State(initialValue: 0)
            _date = State(initialValue: Date())
            _foundingSource = State(initialValue: .other)
        case .edit(let deposit):
            _concept = State(initialValue: deposit.concept)
            _amount = State(initialValue: deposit.amount)
            _date = State(initialValue: deposit.date)
            _foundingSource = State(initialValue: deposit.foundingSource)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $concept)
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Founding Source") {
                    Picker("Founding Source", selection: $foundingSource) {
                        ForEach(FoundingSource.allCases, id: \.self) { source in
                            FoundingSourcePickerView(foundingSource: source)
                        }
                    }
                    .pickerStyle(.navigationLink)
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
                        .disabled(isSaving || concept.isEmpty || amount <= 0)
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

private extension DepositFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .add: "Add deposit"
        case .edit: "Edit deposit"
        }
    }

    /// Keeps the original `id` when editing (the services ignore unknown ids).
    var currentDeposit: Deposit {
        let id: String
        switch mode {
        case .add: id = UUID().uuidString
        case .edit(let original): id = original.id
        }
        return Deposit(id: id, concept: concept, amount: amount, date: date, foundingSource: foundingSource)
    }

    func save() {
        isSaving = true
        let deposit = currentDeposit
        Task {
            do {
                try await onSubmit(deposit)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

// MARK: - Founding Source Picker View

private struct FoundingSourcePickerView: View {
    let foundingSource: FoundingSource

    var body: some View {
        Label {
            Text(foundingSource.rawValue)
        } icon: {
            Image(systemName: foundingSource.icon)
                .foregroundStyle(foundingSource.color)
                .symbolVariant(.fill)
        }
        .tag(foundingSource)
    }
}

// MARK: - Preview

#Preview("Add") {
    DepositFormView(mode: .add) { _ in }
}

#Preview("Edit") {
    DepositFormView(mode: .edit(Deposit.mock)) { _ in }
}

#Preview("Failing submit") {
    struct SubmitError: LocalizedError {
        var errorDescription: String? { "The deposit could not be saved." }
    }

    return DepositFormView(mode: .edit(Deposit.mock)) { _ in throw SubmitError() }
}
