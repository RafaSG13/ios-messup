//
//  ExpenseListRow.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpenseListRow

/// Expense cell that opens the edit sheet on tap and deletes on swipe.
struct ExpenseListRow: View {
    @Environment(\.expenseService) private var expenseService
    let expense: Expense
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?

    var body: some View {
        ExpenseCellView(expense: expense)
            .selectableCell { selectedItem = expense }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive, action: delete)
            }
    }

    private func delete() {
        Task {
            do {
                try await expenseService.delete(expense)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        ExpenseListRow(expense: .mock, selectedItem: .constant(nil), error: .constant(nil))
    }
    .listStyle(.insetGrouped)
}
