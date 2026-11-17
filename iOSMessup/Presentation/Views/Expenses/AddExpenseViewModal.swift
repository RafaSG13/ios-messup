//
//  AddExpenseViewModal.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AddExpenseViewModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var amount: Double = .zero
    @State private var date: Date = .now
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var category: Category = .miscellaneous
    @State private var isSaving = false
    @State private var error: (any Error)?

    var onSubmit: ((_ expense: Expense) async throws -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                DetailsSection(name: $name, amount: $amount, date: $date)
                PaymentMethodSection(paymentMethod: $paymentMethod)
                CategorySection(category: $category)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm, action: save)
                        .disabled(isSaving || name.isEmpty || amount <= 0)
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

private extension AddExpenseViewModal {
    func save() {
        let newExpense = Expense(name: name,
                                 amount: amount,
                                 date: date,
                                 paymentMethod: paymentMethod,
                                 category: category)
        isSaving = true
        Task {
            do {
                try await onSubmit?(newExpense)
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
    @Binding var name: String
    @Binding var amount: Double
    @Binding var date: Date

    var body: some View {
        Section(header: Text("Details")) {
            TextField("Name", text: $name)
            TextField("Amount", value: $amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }
}

fileprivate struct PaymentMethodSection: View {
    @Binding var paymentMethod: PaymentMethod
    var body: some View {
        Section(header: Text("Payment Method")) {
            Picker(selection: $paymentMethod, label: EmptyView()) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    HStack {
                        Text(method.rawValue)
                        Spacer()
                        Image(systemName: method.icon)
                            .foregroundStyle(method.color)
                            .symbolVariant(.fill)
                    }.tag(method)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

fileprivate struct CategorySection: View {
    @Binding var category: Category
    var body: some View {
        Section(header: Text("Category")) {
            Picker(selection: $category, label: EmptyView()) {
                ForEach(Category.allCases, id: \.self) { category in
                    HStack {
                        Text(category.rawValue)
                        Spacer()
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                            .symbolVariant(.fill)
                    }.tag(category)                }
            }
            .pickerStyle(.navigationLink)
        }
    }
}

// MARK: - Preview

#Preview {
    AddExpenseViewModal(onSubmit: nil)
}
