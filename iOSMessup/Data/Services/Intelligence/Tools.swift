//
//  Tools.swift
//  iOSMessup
//

import FoundationModels

// The tool types are `nonisolated` (the model calls them from its own executor) and hold no data: every read of
// the app's state happens inside the `@MainActor` closure, because `Expense`, `PeriodSummary`, etc. are
// main-actor isolated by default.

nonisolated struct SpendingSummaryTool: Tool {
    let name = "getSpendingSummary"
    let description = "Totals for a week, month or year: spent, change vs previous period, projection, budget, top categories, income, net debt cash flow and balance."
    let answer: @MainActor @Sendable (PeriodArguments) -> String

    func call(arguments: PeriodArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct ExpenseSearchTool: Tool {
    let name = "searchExpenses"
    let description = "Find individual expenses by text and/or category within a period."
    let answer: @MainActor @Sendable (ExpenseSearchArguments) -> String

    func call(arguments: ExpenseSearchArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct DebtsTool: Tool {
    let name = "getDebts"
    let description = "Who owes the user money and whom the user owes, with balances and recent history."
    let answer: @MainActor @Sendable (DebtsArguments) -> String

    func call(arguments: DebtsArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct IncomeSearchTool: Tool {
    let name = "searchIncome"
    let description = "Find individual income entries by text within a period."
    let answer: @MainActor @Sendable (IncomeSearchArguments) -> String

    func call(arguments: IncomeSearchArguments) async throws -> String {
        await answer(arguments)
    }
}

// MARK: - Change tools

nonisolated struct ExpenseChangeTool: Tool {
    let name = "changeExpense"
    let description = "Create, update or delete an expense."
    let answer: @MainActor @Sendable (ExpenseChangeArguments) async -> String

    func call(arguments: ExpenseChangeArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct IncomeChangeTool: Tool {
    let name = "changeIncome"
    let description = "Create, update or delete an income entry."
    let answer: @MainActor @Sendable (IncomeChangeArguments) async -> String

    func call(arguments: IncomeChangeArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct BudgetChangeTool: Tool {
    let name = "changeBudget"
    let description = "Set the monthly budget limit or a category limit, or clear the budget."
    let answer: @MainActor @Sendable (BudgetChangeArguments) async -> String

    func call(arguments: BudgetChangeArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct PersonChangeTool: Tool {
    let name = "changePerson"
    let description = "Add, rename or delete a person the user lends to or borrows from."
    let answer: @MainActor @Sendable (PersonChangeArguments) async -> String

    func call(arguments: PersonChangeArguments) async throws -> String {
        await answer(arguments)
    }
}

nonisolated struct DebtChangeTool: Tool {
    let name = "changeDebt"
    let description = "Record, update or delete a loan, borrowing or repayment with a person."
    let answer: @MainActor @Sendable (DebtChangeArguments) async -> String

    func call(arguments: DebtChangeArguments) async throws -> String {
        await answer(arguments)
    }
}