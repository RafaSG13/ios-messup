//
//  IntelligenceService.swift
//  iOSMessup
//

import CoreGraphics
import Foundation
import FoundationModels

/// Apple Foundation Models on the system (on-device) model. One-off requests use a fresh session each; the
/// assistant keeps a session (and its tools) until `resetConversation()` or the context overflows.
@Observable
final class IntelligenceService: IntelligenceServiceProtocol {
    private let expenseService: ExpensesServiceProtocol
    private let incomeService: IncomeServiceProtocol
    private let savingsService: SavingsServiceProtocol
    private let budgetService: BudgetServiceProtocol
    private let model = SystemLanguageModel.default
    @ObservationIgnored private var assistantSession: LanguageModelSession?

    init(expenseService: ExpensesServiceProtocol,
         incomeService: IncomeServiceProtocol,
         savingsService: SavingsServiceProtocol,
         budgetService: BudgetServiceProtocol) {
        self.expenseService = expenseService
        self.incomeService = incomeService
        self.savingsService = savingsService
        self.budgetService = budgetService
    }

    // MARK: - Availability

    var availability: IntelligenceAvailability {
        switch model.availability {
        case .available:
            return model.supportsLocale() ? .available : .unsupportedLanguage
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible: return .deviceNotEligible
            case .appleIntelligenceNotEnabled: return .appleIntelligenceNotEnabled
            case .modelNotReady: return .modelNotReady
            @unknown default: return .modelNotReady
            }
        }
    }

    var canReadImages: Bool {
        model.capabilities.contains(.vision)
    }

    private var currencyCode: String {
        UserDefaults.standard.string(forKey: AppCurrency.storageKey) ?? AppCurrency.defaultCode
    }

    private let greedy = GenerationOptions(samplingMode: .greedy)

    private func requireAvailable() throws {
        guard availability == .available else { throw IntelligenceError.unavailable }
    }

    // MARK: - One-off requests

    func draftExpense(from text: String) async throws -> ExpenseDraft {
        try requireAvailable()
        do {
            let session = LanguageModelSession(model: model,
                                               instructions: IntelligencePrompts.draftInstructions(now: .now, calendar: .current))
            let response = try await session.respond(to: text, generating: GeneratedExpense.self, options: greedy)
            return try Self.validated(ExpenseDraft(response.content, now: .now, calendar: .current))
        } catch {
            throw IntelligenceError.wrap(error)
        }
    }

    func draftExpense(fromReceipt image: CGImage) async throws -> ExpenseDraft {
        try requireAvailable()
        guard canReadImages else { throw IntelligenceError.unavailable }
        do {
            let session = LanguageModelSession(model: model, instructions: IntelligencePrompts.receiptInstructions)
            let response = try await session.respond(generating: GeneratedExpense.self, options: greedy) {
                "Extract the expense from this receipt."
                Attachment(image).label("receipt")
            }
            return try Self.validated(ExpenseDraft(response.content, now: .now, calendar: .current))
        } catch {
            throw IntelligenceError.wrap(error)
        }
    }

    /// A draft with neither a name nor an amount carries nothing the user can use.
    private static func validated(_ draft: ExpenseDraft) throws -> ExpenseDraft {
        guard draft.name != nil || draft.amount != nil else { throw IntelligenceError.couldNotUnderstand }
        return draft
    }

    func suggestCategory(forExpenseNamed name: String) async throws -> Category {
        try requireAvailable()
        do {
            let session = LanguageModelSession(model: SystemLanguageModel(useCase: .contentTagging),
                                               instructions: "Classify a personal expense into one category.")
            let response = try await session.respond(to: "Expense: \(name)", generating: GeneratedCategory.self, options: greedy)
            return Category(response.content)
        } catch {
            throw IntelligenceError.wrap(error)
        }
    }

    // MARK: - Streaming

    func summarize(_ summary: PeriodSummary, monthlyLimit: Double?, currencyCode: String) -> AsyncThrowingStream<String, any Error> {
        guard availability == .available else { return Self.failedStream(IntelligenceError.unavailable) }
        let session = LanguageModelSession(model: model,
                                           instructions: IntelligencePrompts.summaryInstructions(locale: .current))
        let facts = IntelligencePrompts.summaryFacts(summary, monthlyLimit: monthlyLimit, currencyCode: currencyCode)
        return stream(session: session, prompt: facts)
    }

    func ask(_ question: String) -> AsyncThrowingStream<String, any Error> {
        guard availability == .available else { return Self.failedStream(IntelligenceError.unavailable) }
        let session = assistantSession ?? makeAssistantSession()
        assistantSession = session
        return stream(session: session, prompt: question) { [weak self] error in
            if case IntelligenceError.conversationTooLong = error {
                self?.assistantSession = nil
            }
        }
    }

    func resetConversation() {
        assistantSession = nil
    }

    private func stream(session: LanguageModelSession,
                        prompt: String,
                        onError: @escaping (any Error) -> Void = { _ in }) -> AsyncThrowingStream<String, any Error> {
        let options = greedy
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await snapshot in session.streamResponse(to: prompt, options: options) {
                        continuation.yield(snapshot.content)
                    }
                    continuation.finish()
                } catch {
                    let wrapped = IntelligenceError.wrap(error)
                    onError(wrapped)
                    continuation.finish(throwing: wrapped)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func failedStream(_ error: any Error) -> AsyncThrowingStream<String, any Error> {
        AsyncThrowingStream { $0.finish(throwing: error) }
    }

    // MARK: - Assistant

    private func makeAssistantSession() -> LanguageModelSession {
        let spending = SpendingSummaryTool { [weak self] arguments in
            guard let self else { return "No data." }
            let period = self.period(arguments.period, arguments.periodsAgo)
            let summary = PeriodSummary(period: period,
                                        expenses: self.expenseService.expenses,
                                        incomes: self.incomeService.incomes,
                                        contributions: self.savingsService.contributions)
            return IntelligencePrompts.spendingReport(summary, budget: self.budgetService.budget, currencyCode: self.currencyCode)
        }
        let search = ExpenseSearchTool { [weak self] arguments in
            guard let self else { return "No data." }
            return IntelligencePrompts.expenseSearch(self.expenseService.expenses,
                                                     query: arguments.query,
                                                     category: arguments.category.map(Category.init),
                                                     period: self.period(arguments.period, arguments.periodsAgo),
                                                     currencyCode: self.currencyCode)
        }
        let savings = SavingsGoalTool { [weak self] arguments in
            guard let self else { return "No data." }
            return IntelligencePrompts.savingsReport(goal: self.savingsService.savingGoal,
                                                     progress: self.savingsService.progress(),
                                                     contributions: self.savingsService.contributions,
                                                     includeContributions: arguments.includeContributions,
                                                     currencyCode: self.currencyCode)
        }
        return LanguageModelSession(model: model,
                                    tools: [spending, search, savings],
                                    instructions: IntelligencePrompts.assistantInstructions(now: .now, currencyCode: currencyCode))
    }

    private func period(_ kind: String, _ periodsAgo: Int) -> Period {
        IntelligencePrompts.period(kind: PeriodKind(rawValue: kind) ?? .month,
                                   periodsAgo: periodsAgo,
                                   now: .now,
                                   calendar: .current)
    }
}
