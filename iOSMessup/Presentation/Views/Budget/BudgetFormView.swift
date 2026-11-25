//
//  BudgetFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

struct BudgetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.budgetService) private var budgetService
    @State private var monthlyLimit: Double = 0
    @State private var categoryLimits: [Category: Double] = [:]
    @State private var hasLoaded = false
    @State private var isSaving = false
    @State private var isConfirmingRemoval = false
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack {
            Form {
                Section("Monthly limit") {
                    TextField("Monthly limit", value: $monthlyLimit, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                }
                Section("Category limits (optional)") {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryLimitRow(category: category, limit: limitBinding(for: category))
                    }
                }
                if budgetService.budget != nil {
                    Section {
                        Button("Remove budget", role: .destructive) {
                            isConfirmingRemoval = true
                        }
                        .disabled(isSaving)
                    }
                }
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar(isSaveDisabled: isSaving || monthlyLimit <= 0,
                            onCancel: { dismiss() },
                            onSave: save)
            }
            .confirmationDialog("Remove budget?", isPresented: $isConfirmingRemoval, titleVisibility: .visible) {
                Button("Remove budget", role: .destructive, action: remove)
            }
            .errorAlert($error)
            .onAppear(perform: loadExisting)
        }
    }
}

// MARK: - Actions

private extension BudgetFormView {
    func limitBinding(for category: Category) -> Binding<Double?> {
        Binding(get: { categoryLimits[category] },
                set: { categoryLimits[category] = $0 })
    }

    func loadExisting() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard let budget = budgetService.budget else { return }
        monthlyLimit = budget.monthlyLimit
        categoryLimits = budget.categoryLimits
    }

    /// Keeps the existing `id`; empty or zero category limits mean "no limit".
    func save() {
        isSaving = true
        let budget = Budget(id: budgetService.budget?.id ?? UUID().uuidString,
                            monthlyLimit: monthlyLimit,
                            categoryLimits: categoryLimits.filter { $0.value > 0 })
        Task {
            do {
                try await budgetService.saveBudget(budget)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }

    func remove() {
        isSaving = true
        Task {
            do {
                try await budgetService.deleteBudget()
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

// MARK: - CategoryLimitRow

private struct CategoryLimitRow: View {
    @Environment(\.currencyCode) private var currencyCode
    let category: Category
    @Binding var limit: Double?

    var body: some View {
        LabeledContent {
            TextField("No limit", value: $limit, format: .currency(code: currencyCode))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        } label: {
            MUTintedLabel(category.rawValue, systemImage: category.icon, tint: category.color)
        }
    }
}

// MARK: - Preview

#Preview("New") {
    BudgetFormView()
        .environment(\.budgetService, MockBudgetService(initialBudget: nil))
}

#Preview("Existing budget") {
    BudgetFormView()
        .environment(\.budgetService, MockBudgetService())
}

#Preview("Failing") {
    BudgetFormView()
        .environment(\.budgetService, MockBudgetService(shouldFail: true))
}
