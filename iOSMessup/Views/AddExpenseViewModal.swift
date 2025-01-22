//
//  AddExpenseViewModal.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct AddExpenseViewModal: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var expenses: [Expense]
    
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @State private var date: Date = Date()
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var category: Category = .miscellaneous

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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addExpense()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || amount <= 0)
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
            TextField("Name", text: $name)
            TextField("Amount", value: $amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }

    var PaymentMethodSection: some View {
        Section(header: Text("Payment Method")) {
            Picker(selection: $paymentMethod, label: EmptyView()) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    Text(method.rawValue).tag(method)
                }
            }.pickerStyle(.inline)
        }
    }

    var CategorySection: some View {
        Section(header: Text("Category")) {
            Picker(selection: $category, label: Text("Select a Category")) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
}

// MARK: - Private Methods

extension AddExpenseViewModal {
    func addExpense() {
        let newExpense = Expense(
            name: name,
            amount: amount,
            date: date,
            paymentMethod: paymentMethod,
            category: category
        )
        expenses.append(newExpense)
    }
}

// MARK: - Preview

#Preview {
    AddExpenseViewModal(expenses: .constant(Expense.mockArray))
}
