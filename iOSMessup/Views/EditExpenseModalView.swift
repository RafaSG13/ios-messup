//
//  EditExpenseModalView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct EditExpenseModalView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var expense: Expense

    var onSubmit: ((_ expense: Expense) async throws -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $expense.name)
                    TextField("Amount", value: $expense.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                }
                
                Section(header: Text("Payment Method")) {
                    Picker(selection: $expense.paymentMethod, label: EmptyView()) {
                        ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                            Text(paymentMethod.rawValue).tag(paymentMethod)
                        }
                    }.pickerStyle(.inline)
                }
                
                Section(header: Text("Category")) {
                    Picker(selection: $expense.category, label: Text("Select a Category")) {
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
                        Task {
                            try? await onSubmit?(expense)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditExpenseModalView(expense: .mock)
        .environment(ExpenseViewModel(dataSource: ExpensesDataSourceSpy()))
}
