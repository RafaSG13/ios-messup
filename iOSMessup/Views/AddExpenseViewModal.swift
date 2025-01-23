//
//  AddExpenseViewModal.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AddExpenseViewModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var newExpense: Expense = Expense(name: "",
                                                     amount: 0.0,
                                                     date: Date(),
                                                     paymentMethod: .cash,
                                                     category: .miscellaneous)
    var onSubmit: ((_ expense: Expense) async throws -> Void)?

    var body: some View {
        NavigationView {
            Form {
                DetailsSection
                PaymentMethodSection
                CategorySection
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                           try? await onSubmit?(newExpense)
                        }
                        dismiss()
                    }
                    .disabled(newExpense.name.isEmpty || newExpense.amount <= 0)
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
        }
    }
}

//MARK: View Components

private extension AddExpenseViewModal {
    var DetailsSection: some View {
        Section(header: Text("Details")) {
            TextField("Name", text: $newExpense.name)
            TextField("Amount", value: $newExpense.amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            DatePicker("Date", selection: $newExpense.date, displayedComponents: .date)
        }
    }

    var PaymentMethodSection: some View {
        Section(header: Text("Payment Method")) {
            Picker(selection: $newExpense.paymentMethod, label: EmptyView()) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }.pickerStyle(.inline)
        }
    }

    var CategorySection: some View {
        Section(header: Text("Category")) {
            Picker(selection: $newExpense.category, label: Text("Select a Category")) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
}

// MARK: - Preview

#Preview {
    AddExpenseViewModal(onSubmit: nil)
}
