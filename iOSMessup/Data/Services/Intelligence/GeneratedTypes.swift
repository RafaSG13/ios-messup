//
//  GeneratedTypes.swift
//  iOSMessup
//

import FoundationModels

// Everything the model produces or receives is `nonisolated`: the types are plain values and must be usable from
// the model's executor. Mapping to the domain lives in `GeneratedMapping.swift`.

@Generable
nonisolated enum GeneratedCategory: CaseIterable {
    case entertainment, travel, food, transportation, health, home, technology
    case fashion, education, family, finance, taxes, charity, miscellaneous
}

@Generable
nonisolated enum GeneratedPaymentMethod: CaseIterable {
    case cash, creditCard, debitCard, paypal, other
}

@Generable
nonisolated struct GeneratedExpense {
    @Guide(description: "Short merchant or item name, e.g. 'Coffee' or 'Mercadona'. Empty if unknown.")
    var name: String

    @Guide(description: "Total amount paid as a plain number, without currency symbol.", .minimum(0))
    var amount: Double?

    @Guide(description: "Purchase date as yyyy-MM-dd, only when an explicit date is given (e.g. printed on a receipt).")
    var date: String?

    @Guide(description: "Days before today: 0 today, 1 yesterday. Only when said relatively.", .range(0...365))
    var daysAgo: Int?

    @Guide(description: "How it was paid, when mentioned.")
    var paymentMethod: GeneratedPaymentMethod?

    @Guide(description: "Best matching category.")
    var category: GeneratedCategory?
}

// MARK: - Tool arguments

@Generable
nonisolated struct PeriodArguments {
    @Guide(description: "Length of the period.", .anyOf(["week", "month", "year"]))
    var period: String

    @Guide(description: "0 is the current period, 1 the previous one, 2 the one before that…", .range(0...24))
    var periodsAgo: Int
}

@Generable
nonisolated struct ExpenseSearchArguments {
    @Guide(description: "Text to match in the expense name.")
    var query: String?

    @Guide(description: "Only expenses of this category.")
    var category: GeneratedCategory?

    @Guide(description: "Length of the period.", .anyOf(["week", "month", "year"]))
    var period: String

    @Guide(description: "0 is the current period, 1 the previous one, 2 the one before that…", .range(0...24))
    var periodsAgo: Int
}

@Generable
nonisolated struct DebtsArguments {
    @Guide(description: "Name of one person, or empty for everyone.")
    var personName: String?
}

@Generable
nonisolated struct IncomeSearchArguments {
    @Guide(description: "Text to match in the income concept.")
    var query: String?

    @Guide(description: "Length of the period.", .anyOf(["week", "month", "year"]))
    var period: String

    @Guide(description: "0 is the current period, 1 the previous one, 2 the one before that…", .range(0...24))
    var periodsAgo: Int
}

// MARK: - Change types

@Generable
nonisolated enum GeneratedChangeAction {
    case create, update, delete
}

@Generable
nonisolated enum GeneratedPersonAction {
    case add, rename, delete
}

@Generable
nonisolated enum GeneratedBudgetAction {
    case set, clear
}

@Generable
nonisolated enum GeneratedDebtKind {
    case lent, borrowed, receivedPayment, madePayment
}

@Generable
nonisolated enum GeneratedIncomeSource {
    case salary, freelance, investments, rentalIncome, businessProfits, gifts, inheritance
    case bonuses, taxRefund, passiveIncome, sellingAssets, sideHustle, governmentBenefits, other
}

@Generable
nonisolated struct ExpenseChangeArguments {
    @Guide(description: "create a new expense, update or delete an existing one.")
    var action: GeneratedChangeAction

    @Guide(description: "Required for update and delete: the #ref copied from a search result.")
    var ref: String?

    @Guide(description: "Merchant or item name. Required for create.")
    var name: String?

    @Guide(description: "Amount as a plain number. Required for create.", .minimum(0))
    var amount: Double?

    @Guide(description: "Date as yyyy-MM-dd, only when explicitly given.")
    var date: String?

    @Guide(description: "Days before today: 0 today, 1 yesterday. Only when said relatively.", .range(0...365))
    var daysAgo: Int?

    @Guide(description: "How it was paid, when mentioned.")
    var paymentMethod: GeneratedPaymentMethod?

    @Guide(description: "Best matching category.")
    var category: GeneratedCategory?
}

@Generable
nonisolated struct IncomeChangeArguments {
    @Guide(description: "create a new income, update or delete an existing one.")
    var action: GeneratedChangeAction

    @Guide(description: "Required for update and delete: the #ref copied from a search result.")
    var ref: String?

    @Guide(description: "What the money is for, e.g. 'Salary'. Required for create.")
    var concept: String?

    @Guide(description: "Amount as a plain number. Required for create.", .minimum(0))
    var amount: Double?

    @Guide(description: "Date as yyyy-MM-dd, only when explicitly given.")
    var date: String?

    @Guide(description: "Days before today: 0 today, 1 yesterday. Only when said relatively.", .range(0...365))
    var daysAgo: Int?

    @Guide(description: "Where the money comes from.")
    var source: GeneratedIncomeSource?
}

@Generable
nonisolated struct BudgetChangeArguments {
    @Guide(description: "set the limits, or clear the whole budget.")
    var action: GeneratedBudgetAction

    @Guide(description: "Monthly limit as a plain number.", .minimum(0))
    var monthlyLimit: Double?

    @Guide(description: "Category whose own limit is set; needs categoryLimit.")
    var category: GeneratedCategory?

    @Guide(description: "Limit for that category; 0 removes it.", .minimum(0))
    var categoryLimit: Double?
}

@Generable
nonisolated struct PersonChangeArguments {
    @Guide(description: "add a person, rename one, or delete one with their debts.")
    var action: GeneratedPersonAction

    @Guide(description: "The person's name (the current name for rename and delete).")
    var name: String

    @Guide(description: "The new name. Required for rename.")
    var newName: String?
}

@Generable
nonisolated struct DebtChangeArguments {
    @Guide(description: "create a new entry, update or delete an existing one.")
    var action: GeneratedChangeAction

    @Guide(description: "Required for update and delete: the #ref copied from getDebts.")
    var ref: String?

    @Guide(description: "The person's name. Required for create.")
    var personName: String?

    @Guide(description: "lent: user lent money. borrowed: user borrowed. receivedPayment: they paid the user back. madePayment: user paid them back.")
    var kind: GeneratedDebtKind?

    @Guide(description: "Amount as a plain number. Required for create.", .minimum(0))
    var amount: Double?

    @Guide(description: "Date as yyyy-MM-dd, only when explicitly given.")
    var date: String?

    @Guide(description: "Days before today: 0 today, 1 yesterday. Only when said relatively.", .range(0...365))
    var daysAgo: Int?

    @Guide(description: "Optional short note.")
    var note: String?
}
