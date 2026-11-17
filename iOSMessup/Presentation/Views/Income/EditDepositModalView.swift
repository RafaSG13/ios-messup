//
//  EditDepositModalView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct EditDepositModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var deposit: Deposit

    @State private var isSaving = false
    @State private var error: (any Error)?
    private var onSubmit: (_ deposit: Deposit) async throws -> Void

    init(deposit: Deposit, onSubmit: @escaping (_: Deposit) async throws -> Void) {
        self.deposit = deposit
        self.onSubmit = onSubmit
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $deposit.concept)
                    TextField("Amount", value: $deposit.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $deposit.date, displayedComponents: .date)
                }

                Section(header: Text("Founding Source")) {
                    Picker(selection: $deposit.foundingSource, label: EmptyView()) {
                        ForEach(FoundingSource.allCases, id: \.self) { source in
                            FoundingSourcePickerView(foundingSource: source)
                        }
                    }.pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("Edit deposit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm, action: save)
                        .disabled(isSaving)
                }
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension EditDepositModalView {
    func save() {
        isSaving = true
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

//MARK: - Founding Source Picker View

struct FoundingSourcePickerView: View {
    let foundingSource: FoundingSource

    var body: some View {
        HStack {
            Text(foundingSource.rawValue)
            Spacer()
            Image(systemName: foundingSource.icon)
                .foregroundStyle(foundingSource.color)
                .symbolVariant(.fill)
        }.tag(foundingSource)
    }
}

#Preview {
    EditDepositModalView(deposit: Deposit.mock, onSubmit: { _ in })
}
