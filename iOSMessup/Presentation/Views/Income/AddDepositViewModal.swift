//
//  AddDepositViewModal.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI

struct AddDepositViewModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var newDeposit: Deposit = Deposit(concept: "",
                                                     amount: 0.0,
                                                     date: Date(),
                                                     foundingSource: .other)
    @State private var isSaving = false
    @State private var error: (any Error)?
    var onSubmit: ((_ Deposit: Deposit) async throws -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                DetailsSection(newDeposit: $newDeposit)
                PaymentMethodSection(newDeposit: $newDeposit)
            }
            .navigationTitle("Add Deposit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .disabled(isSaving || newDeposit.concept.isEmpty || newDeposit.amount <= 0)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }.tint(.blue)
                    }
                }
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension AddDepositViewModal {
    func save() {
        isSaving = true
        Task {
            do {
                try await onSubmit?(newDeposit)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

//MARK: View Components

fileprivate struct DetailsSection: View {
    @Binding var newDeposit: Deposit
    var body: some View {
        Section(header: Text("Details")) {
            TextField("Concept", text: $newDeposit.concept)
            TextField("Amount", value: $newDeposit.amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            DatePicker("Date", selection: $newDeposit.date, displayedComponents: .date)
        }
    }
}

fileprivate struct PaymentMethodSection: View {
    @Binding var newDeposit: Deposit
    var body: some View {
        Section(header: Text("Founding Source")) {
            Picker(selection: $newDeposit.foundingSource, label: EmptyView()) {
                ForEach(FoundingSource.allCases, id: \.self) { source in
                    HStack {
                        Text(source.rawValue)
                        Spacer()
                        Image(systemName: source.icon)
                            .foregroundStyle(source.color)
                            .symbolVariant(.fill)
                    }.tag(source)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
}

// MARK: - Preview

#Preview {
    AddDepositViewModal(onSubmit: nil)
}
