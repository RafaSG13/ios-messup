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

    private var onSubmit: (_ deposit: Deposit) async throws -> Void

    init(deposit: Deposit, onSubmit: @escaping (_: Deposit) async throws -> Void) {
        self.deposit = deposit
        self.onSubmit = onSubmit
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $deposit.concept)
                    TextField("Amount", value: $deposit.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $deposit.date, displayedComponents: .date)
                }

                Section(header: Text("Founding Source")) {
                    Picker(selection: $deposit.foundingSource, label: EmptyView()) {
                        ForEach(FoundingSource.allCases, id: \.self) { category in
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
            .navigationTitle("Edit deposit")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            try? await onSubmit(deposit)
                        }
                        dismiss()
                    }
                }
            }.buttonStyle(.plain)
        }
    }
}

#Preview {
    EditDepositModalView(deposit: Deposit.mock, onSubmit: { _ in })
}
