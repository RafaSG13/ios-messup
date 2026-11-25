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
nonisolated struct SavingsArguments {
    @Guide(description: "Whether to list the latest contributions")
    var includeContributions: Bool
}
