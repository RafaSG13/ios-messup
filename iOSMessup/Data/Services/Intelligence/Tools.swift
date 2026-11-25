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
    let description = "Totals for a week, month or year: spent, change vs previous period, projection, budget, top categories, income, savings and balance."
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

nonisolated struct SavingsGoalTool: Tool {
    let name = "getSavingGoal"
    let description = "The saving goal, its progress and recent contributions."
    let answer: @MainActor @Sendable (SavingsArguments) -> String

    func call(arguments: SavingsArguments) async throws -> String {
        await answer(arguments)
    }
}
