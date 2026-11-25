//
//  SavingGoalFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

struct SavingGoalFormView: View {
    enum Mode: Identifiable {
        case create
        case edit(SavingGoal)

        var id: String {
            switch self {
            case .create: "create"
            case .edit(let goal): goal.id
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @State private var name: String
    @State private var amount: Double
    @State private var category: SavingCategory
    @State private var hasTargetDate: Bool
    @State private var targetDate: Date
    @State private var isSaving = false
    @State private var error: (any Error)?

    private let mode: Mode
    private let onSubmit: (SavingGoal) async throws -> Void

    init(mode: Mode, onSubmit: @escaping (SavingGoal) async throws -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        let defaultDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        switch mode {
        case .create:
            _name = State(initialValue: "")
            _amount = State(initialValue: 0)
            _category = State(initialValue: .vacation)
            _hasTargetDate = State(initialValue: false)
            _targetDate = State(initialValue: defaultDate)
        case .edit(let goal):
            _name = State(initialValue: goal.name)
            _amount = State(initialValue: goal.amount)
            _category = State(initialValue: goal.savingCategory)
            _hasTargetDate = State(initialValue: goal.completionDate.date != nil)
            _targetDate = State(initialValue: goal.completionDate.date ?? defaultDate)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Target amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(SavingCategory.allCases, id: \.self) { category in
                            MUTintedLabel(category.rawValue, systemImage: category.icon, tint: category.color)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Target date") {
                    Toggle("Set a target date", isOn: $hasTargetDate.animation())
                    if hasTargetDate {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar(isSaveDisabled: isSaving || name.isEmpty || amount <= 0,
                            onCancel: { dismiss() },
                            onSave: save)
            }
            .errorAlert($error)
        }
    }
}

// MARK: - Actions

private extension SavingGoalFormView {
    var title: LocalizedStringKey {
        switch mode {
        case .create: "New saving goal"
        case .edit: "Edit saving goal"
        }
    }

    /// Keeps the original `id` when editing.
    var currentGoal: SavingGoal {
        let id: String
        switch mode {
        case .create: id = UUID().uuidString
        case .edit(let original): id = original.id
        }
        return SavingGoal(id: id,
                          name: name,
                          completionDate: hasTargetDate ? .fixed(targetDate) : .undefined,
                          amount: amount,
                          savingCategory: category)
    }

    func save() {
        isSaving = true
        let goal = currentGoal
        Task {
            do {
                try await onSubmit(goal)
                dismiss()
            } catch {
                self.error = error
                isSaving = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Create") {
    SavingGoalFormView(mode: .create) { _ in }
}

#Preview("Edit") {
    SavingGoalFormView(mode: .edit(SavingGoal.mock)) { _ in }
}

#Preview("Edit, no date") {
    SavingGoalFormView(mode: .edit(SavingGoal.mockArray[2])) { _ in }
}

#Preview("Failing submit") {
    struct SubmitError: LocalizedError {
        var errorDescription: String? { "The saving goal could not be saved." }
    }

    return SavingGoalFormView(mode: .edit(SavingGoal.mock)) { _ in throw SubmitError() }
}
