//
//  LiveIntelligenceTests.swift
//  iOSMessupTests
//

import Foundation
import FoundationModels
import Testing
@testable import iOSMessup

/// Runs only on a device where the on-device model is available. The simulator is excluded: it can report the model
/// as available while its assets are missing, and generation then fails or never returns.
struct LiveIntelligenceTests {
    nonisolated private static var canRunLiveModel: Bool {
        #if targetEnvironment(simulator)
        false
        #else
        SystemLanguageModel.default.isAvailable
        #endif
    }

    @Test(.enabled(if: LiveIntelligenceTests.canRunLiveModel), .timeLimit(.minutes(1)))
    func draftsAnExpenseFromText() async throws {
        let service = IntelligenceService(expenseService: MockExpensesService(delay: 0),
                                          incomeService: MockIncomeService(delay: 0),
                                          debtsService: MockDebtsService(delay: 0),
                                          budgetService: MockBudgetService(delay: 0))

        let draft = try await service.draftExpense(from: "Coffee 3.50 paid in cash yesterday")

        #expect(draft.amount == 3.5)
        #expect(draft.paymentMethod == .cash)
    }

    @Test(.enabled(if: LiveIntelligenceTests.canRunLiveModel), .timeLimit(.minutes(1)))
    func assistantToolsAndInstructionsFitHalfTheContext() async throws {
        let service = IntelligenceService(expenseService: MockExpensesService(delay: 0),
                                          incomeService: MockIncomeService(delay: 0),
                                          debtsService: MockDebtsService(delay: 0),
                                          budgetService: MockBudgetService(delay: 0))
        let model = SystemLanguageModel.default
        let tools = service.assistantTools()
        let instructions = Instructions(IntelligencePrompts.assistantInstructions(now: .now, currencyCode: "EUR"))

        let used = try await model.tokenCount(for: tools) + model.tokenCount(for: instructions)

        #expect(tools.count == 9)
        #expect(used < model.contextSize / 2)
    }
}
