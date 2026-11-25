//
//  ExpenseFormView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import PhotosUI
import SwiftUI
import MUDesignSystem

// MARK: - ExpenseFormView

/// Add / edit form for an expense. In edit mode the saved expense keeps the original `id`.
/// In add mode, when Apple Intelligence is available, the form can be filled from text, a photo or a scanned receipt,
/// and the category is suggested from the name until the user picks one.
struct ExpenseFormView: View {
    enum Mode {
        case add
        case edit(Expense)
    }

    /// Who set the current category. A saved expense (edit) and any manual pick are never overwritten.
    private enum CategorySource {
        case automatic
        case intelligence
        case user
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var name: String
    @State private var amount: Double
    @State private var date: Date
    @State private var paymentMethod: PaymentMethod
    @State private var category: Category
    @State private var categorySource: CategorySource
    @State private var isSaving = false
    @State private var quickText = ""
    @State private var isGenerating = false
    @State private var photoItem: PhotosPickerItem?
    @State private var isScanning = false
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
            _categorySource = State(initialValue: .automatic)
        case .edit(let expense):
            _name = State(initialValue: expense.name)
            _amount = State(initialValue: expense.amount)
            _date = State(initialValue: expense.date)
            _paymentMethod = State(initialValue: expense.paymentMethod)
            _category = State(initialValue: expense.category)
            _categorySource = State(initialValue: .user)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if showsIntelligence {
                    intelligenceSection
                }

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

                Section {
                    Picker("Category", selection: categoryBinding) {
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
                } header: {
                    Text("Category")
                } footer: {
                    if categorySource == .intelligence {
                        Label("Suggested by Apple Intelligence", systemImage: "sparkles")
                    }
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
            .task(id: name) { await suggestCategory() }
            .onChange(of: photoItem) { _, item in
                if let item { read(item) }
            }
            .fullScreenCover(isPresented: $isScanning) {
                DocumentScannerView(onScan: { image in
                    isScanning = false
                    read(image)
                }, onCancel: {
                    isScanning = false
                })
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Apple Intelligence section

private extension ExpenseFormView {
    var showsIntelligence: Bool {
        if case .add = mode { return intelligenceService.availability == .available }
        return false
    }

    var intelligenceSection: some View {
        Section {
            TextField("Describe it, e.g. Coffee 3.50 by card yesterday", text: $quickText, axis: .vertical)
            HStack {
                Button("Fill in", systemImage: "sparkles", action: fillFromText)
                    .disabled(quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                if intelligenceService.canReadImages {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Photo", systemImage: "photo")
                    }
                    if DocumentScannerView.isSupported {
                        Button("Scan", systemImage: "doc.viewfinder") { isScanning = true }
                    }
                }
                if isGenerating {
                    ProgressView()
                }
            }
            .buttonStyle(.bordered)
        } header: {
            Label("Apple Intelligence", systemImage: "sparkles")
        } footer: {
            Text("Check the details before saving.")
        }
    }

    /// Run `draft`, fill the form with the result or show the error. Only one request at a time.
    func generate(_ draft: @escaping () async throws -> ExpenseDraft) {
        guard !isGenerating else { return }
        isGenerating = true
        Task {
            do {
                apply(try await draft())
            } catch {
                self.error = error
            }
            isGenerating = false
            photoItem = nil
        }
    }

    func fillFromText() {
        let text = quickText
        generate { try await intelligenceService.draftExpense(from: text) }
    }

    func read(_ item: PhotosPickerItem) {
        generate {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = ReceiptImageLoader.cgImage(from: data) else {
                throw IntelligenceError.unreadableImage
            }
            return try await intelligenceService.draftExpense(fromReceipt: image)
        }
    }

    func read(_ image: CGImage) {
        generate { try await intelligenceService.draftExpense(fromReceipt: image) }
    }

    /// Only the fields the model found are overwritten.
    func apply(_ draft: ExpenseDraft) {
        if let value = draft.name { name = value }
        if let value = draft.amount { amount = value }
        if let value = draft.date { date = value }
        if let value = draft.paymentMethod { paymentMethod = value }
        if let value = draft.category {
            category = value
            categorySource = .intelligence
        }
    }

    var categoryBinding: Binding<Category> {
        Binding(get: { category },
                set: {
                    category = $0
                    categorySource = .user
                })
    }

    /// Suggests a category once the name settles. Errors are ignored on purpose: the suggestion is optional.
    func suggestCategory() async {
        guard categorySource != .user,
              intelligenceService.availability == .available,
              name.trimmingCharacters(in: .whitespaces).count >= 3 else { return }
        try? await Task.sleep(for: .milliseconds(600))
        guard !Task.isCancelled else { return }
        if let suggested = try? await intelligenceService.suggestCategory(forExpenseNamed: name),
           categorySource != .user {
            category = suggested
            categorySource = .intelligence
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

#Preview("Add, Apple Intelligence off") {
    ExpenseFormView(mode: .add, onSubmit: { _ in })
        .environment(\.intelligenceService, MockIntelligenceService(availability: .appleIntelligenceNotEnabled))
}

#Preview("Edit") {
    ExpenseFormView(mode: .edit(.mock), onSubmit: { _ in })
}

#Preview("Failing service") {
    ExpenseFormView(mode: .add, onSubmit: MockExpensesService(shouldFail: true).addExpense)
}
