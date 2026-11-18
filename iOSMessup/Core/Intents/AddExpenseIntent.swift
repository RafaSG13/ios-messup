//
//  AddExpenseIntent.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import AppIntents
import Foundation

// MARK: - AddExpenseIntent

/// Records an expense from Siri, Shortcuts, Spotlight or the Action button. Runs inside the app process with the
/// same services as the UI.
struct AddExpenseIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Add expense"
    nonisolated static let description = IntentDescription("Record an expense in Messup.")

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Name")
    var name: String

    @Parameter(title: "Category", default: .miscellaneous)
    var category: Category

    @Parameter(title: "Payment method", default: .cash)
    var paymentMethod: PaymentMethod

    nonisolated static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) for \(\.$name)") {
            \.$category
            \.$paymentMethod
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let services = AppServices.shared
        let code = UserDefaults.standard.string(forKey: AppCurrency.storageKey) ?? AppCurrency.defaultCode
        let expense = try await record(in: services.expenseService)
        try await services.budgetService.load()
        await BudgetAlertChecker.check(expenses: services.expenseService.expenses,
                                       budget: services.budgetService.budget,
                                       notifications: services.notificationService,
                                       currencyCode: code)
        return .result(dialog: "Added \(expense.amount.formattedMoney(code: code)) for \(expense.name).")
    }

    /// Validates the input and saves the expense dated now.
    @MainActor
    func record(in service: ExpensesServiceProtocol, now: Date = .now) async throws -> Expense {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard amount > 0 else { throw AddExpenseIntentError.invalidAmount }
        guard !trimmed.isEmpty else { throw AddExpenseIntentError.emptyName }
        let expense = Expense(name: trimmed, amount: amount, date: now, paymentMethod: paymentMethod, category: category)
        try await service.addExpense(expense)
        return expense
    }
}

enum AddExpenseIntentError: Error, CustomLocalizedStringResourceConvertible {
    case invalidAmount
    case emptyName

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidAmount: "The amount must be greater than zero."
        case .emptyName: "The expense needs a name."
        }
    }
}

// MARK: - Shortcuts

struct MessupShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddExpenseIntent(),
                    phrases: ["Add an expense in \(.applicationName)",
                              "Log spending in \(.applicationName)"],
                    shortTitle: "Add expense",
                    systemImageName: "plus.circle")
    }
}

// MARK: - AppEnum conformances

extension Category: AppEnum {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"

    nonisolated static let caseDisplayRepresentations: [Category: DisplayRepresentation] = [
        .entertainment: "Entertainment",
        .travel: "Travel",
        .food: "Food",
        .transportation: "Transportation",
        .health: "Health and Wellness",
        .home: "Home",
        .technology: "Technology and Communications",
        .fashion: "Fashion and Beauty",
        .education: "Education and Learning",
        .family: "Family and Pets",
        .finance: "Finance and Insurance",
        .taxes: "Taxes and Obligations",
        .charity: "Donations and Charity",
        .miscellaneous: "Miscellaneous"
    ]
}

extension PaymentMethod: AppEnum {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Payment method"

    nonisolated static let caseDisplayRepresentations: [PaymentMethod: DisplayRepresentation] = [
        .cash: "Cash",
        .creditCard: "Credit Card",
        .debitCard: "Debit Card",
        .paypal: "Paypal",
        .other: "Other"
    ]
}
