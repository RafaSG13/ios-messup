//
//  IncomeFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

struct IncomeFormView: View {
    enum Mode {
        case add
        case edit(Income)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var concept: String
    @State private var amount: Double
    @State private var date: Date
    @State private var source: IncomeSource
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (Income) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (Income) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add:
            _concept = State(initialValue: "")
            _amount = State(initialValue: 0)
            _date = State(initialValue: Date())
            _source = State(initialValue: .other)
        case .edit(let income):
            _concept = State(initialValue: income.concept)
            _amount = State(initialValue: income.amount)
            _date = State(initialValue: income.date)
            _source = State(initialValue: income.source)
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

                Section("Source") {
                    Picker("Source", selection: $source) {
                        ForEach(IncomeSource.allCases, id: \.self) { source in
                            MUTintedLabel(source.rawValue, systemImage: source.icon, tint: source.color)
                                .tag(source)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar(isSaveDisabled: isSaving || concept.isEmpty || amount <= 0,
                            onCancel: { dismiss() },
                            onSave: save)
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension IncomeFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .add: "Add income"
        case .edit: "Edit income"
        }
    }

    /// Keeps the original `id` when editing (the services ignore unknown ids).
    var currentIncome: Income {
        let id: String
        switch mode {
        case .add: id = UUID().uuidString
        case .edit(let original): id = original.id
        }
        return Income(id: id, concept: concept, amount: amount, date: date, source: source)
    }

    func save() {
        isSaving = true
        let income = currentIncome
        Task {
            do {
                try await onSubmit(income)
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
    IncomeFormView(mode: .add) { _ in }
}

#Preview("Edit") {
    IncomeFormView(mode: .edit(Income.mock)) { _ in }
}

#Preview("Failing submit") {
    struct SubmitError: LocalizedError {
        var errorDescription: String? { "The income could not be saved." }
    }

    return IncomeFormView(mode: .edit(Income.mock)) { _ in throw SubmitError() }
}
