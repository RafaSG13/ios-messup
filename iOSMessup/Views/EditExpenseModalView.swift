//
//  EditExpenseModalView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct EditExpenseModalView: View {
    @Binding var expense: Expense
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String
    @State private var amount: Double
    @State private var date: Date
    @State private var paymentMethod: PaymentMethod
    @State private var category: Category

    init(expense: Binding<Expense>) {
        _expense = expense
        _name = State(initialValue: expense.wrappedValue.name)
        _amount = State(initialValue: expense.wrappedValue.amount)
        _date = State(initialValue: expense.wrappedValue.date)
        _paymentMethod = State(initialValue: expense.wrappedValue.paymentMethod)
        _category = State(initialValue: expense.wrappedValue.category)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Amount", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Payment Method")) {
                    Picker(selection: $paymentMethod, label: EmptyView()) {
                        ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                            Text(paymentMethod.rawValue).tag(paymentMethod)
                        }
                    }.pickerStyle(.inline)
                }

                Section(header: Text("Category")) {
                    Picker(selection: $category, label: Text("Select a Category")) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }.pickerStyle(.navigationLink)
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        applyChanges()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

private extension EditExpenseModalView {
    func applyChanges() {
        expense.name = name
        expense.amount = amount
        expense.date = date
        expense.paymentMethod = paymentMethod
        expense.category = category
    }
}

#Preview {
    EditExpenseModalView(expense: .constant(.mock))
}
