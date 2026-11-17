//
//  ExpenseFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

// MARK: - ExpenseFormView

/// Add / edit form for an expense. In edit mode the saved expense keeps the original `id`.
struct ExpenseFormView: View {
    enum Mode {
        case add
        case edit(Expense)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var name: String
    @State private var amount: Double
    @State private var date: Date
    @State private var paymentMethod: PaymentMethod
    @State private var category: Category
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (_ expense: Expense) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (_ expense: Expense) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add:
            _name = State(initialValue: "")
            _amount = State(initialValue: 0)
            _date = State(initialValue: .now)
            _paymentMethod = State(initialValue: .cash)
            _category = State(initialValue: .miscellaneous)
        case .edit(let expense):
            _name = State(initialValue: expense.name)
            _amount = State(initialValue: expense.amount)
            _date = State(initialValue: expense.date)
            _paymentMethod = State(initialValue: expense.paymentMethod)
            _category = State(initialValue: expense.category)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Payment Method") {
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            HStack {
                                Text(method.rawValue)
                                Spacer()
                                Image(systemName: method.icon)
                                    .foregroundStyle(method.color)
                                    .symbolVariant(.fill)
                            }
                            .tag(method)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                                    .symbolVariant(.fill)
                            }
                            .tag(category)
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
                        .disabled(isSaving || name.isEmpty || amount <= 0)
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

private extension ExpenseFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .add: "Add Expense"
        case .edit: "Edit Expense"
        }
    }

    func save() {
        let id: String
        switch mode {
        case .add: id = UUID().uuidString
        case .edit(let expense): id = expense.id
        }
        let expense = Expense(id: id,
                              name: name,
                              amount: amount,
                              date: date,
                              paymentMethod: paymentMethod,
                              category: category)
        isSaving = true
        Task {
            do {
                try await onSubmit(expense)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

// MARK: - Previews

#Preview("Add") {
    ExpenseFormView(mode: .add, onSubmit: { _ in })
}

#Preview("Edit") {
    ExpenseFormView(mode: .edit(.mock), onSubmit: { _ in })
}

#Preview("Failing service") {
    ExpenseFormView(mode: .add, onSubmit: MockExpensesService(shouldFail: true).addExpense)
}
