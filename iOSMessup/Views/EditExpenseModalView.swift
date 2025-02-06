//
//  EditExpenseModalView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct EditExpenseModalView: View {
    @Environment(\.dismiss) private var dismiss
    let expense: Expense
    var onSubmit: (_ expense: Expense) async throws -> Void

    @State private var name: String = ""
    @State private var amount: Double = 0.0
    @State private var date: Date = Date()
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var category: Category = .miscellaneous

    var body: some View {
        NavigationView {
            Form {
                DetailSection(name: $name, amount: $amount, date: $date)
                PaymentSection(paymentMethod: $paymentMethod)
                CategorySection(category: $category)
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let newExpense = Expense(name: name,
                                                     amount: amount,
                                                     date: date,
                                                     paymentMethod: paymentMethod,
                                                     category: category)
                            try? await onSubmit(newExpense)
                        }
                        dismiss()
                    }
                }
            }.buttonStyle(.plain)
        }
        .onAppear {
            name = expense.name
            amount = expense.amount
            date = expense.date
            paymentMethod = expense.paymentMethod
            category = expense.category
        }
    }
}

//MARK: View Components

fileprivate struct DetailSection: View {
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

fileprivate struct PaymentSection: View {
    @Binding var paymentMethod: PaymentMethod
    var body: some View {
        Section(header: Text("Payment Method")) {
            Picker(selection: $paymentMethod, label: EmptyView()) {
                ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                    HStack {
                        Text(paymentMethod.rawValue)
                        Spacer()
                        Image(systemName: paymentMethod.icon)
                            .foregroundStyle(paymentMethod.color)
                            .symbolVariant(.fill)
                    }.tag(paymentMethod)
                }
            }.pickerStyle(.inline)
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
                    }.tag(category)
                }
            }.pickerStyle(.navigationLink)
        }
    }
}


#Preview {
    EditExpenseModalView(expense: .mock, onSubmit: { _ in })
}
