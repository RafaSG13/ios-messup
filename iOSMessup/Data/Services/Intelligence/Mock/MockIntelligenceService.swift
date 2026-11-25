//
//  MockIntelligenceService.swift
//  iOSMessup
//

import CoreGraphics
import Foundation
import Observation

@Observable
final class MockIntelligenceService: IntelligenceServiceProtocol {
    var availability: IntelligenceAvailability
    var canReadImages: Bool
    var draft: ExpenseDraft
    var suggestedCategory: Category
    var reply: String
    var delay: TimeInterval
    var shouldFail: Bool

    init(availability: IntelligenceAvailability = .available,
         canReadImages: Bool = true,
         draft: ExpenseDraft = ExpenseDraft(name: "Coffee", amount: 3.5, date: nil, paymentMethod: .creditCard, category: .food),
         suggestedCategory: Category = .food,
         reply: String = "You spent 1,436.02 € this month, 36 % less than last month. Home is your biggest category.",
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.availability = availability
        self.canReadImages = canReadImages
        self.draft = draft
        self.suggestedCategory = suggestedCategory
        self.reply = reply
        self.delay = delay
        self.shouldFail = shouldFail
    }

    private func simulateWork() async throws {
        try await Task.sleep(for: .seconds(delay))
        if shouldFail { throw IntelligenceError.failed }
    }

    func draftExpense(from text: String) async throws -> ExpenseDraft {
        try await simulateWork()
        return draft
    }

    func draftExpense(fromReceipt image: CGImage) async throws -> ExpenseDraft {
        try await simulateWork()
        return draft
    }

    func suggestCategory(forExpenseNamed name: String) async throws -> Category {
        try await simulateWork()
        return suggestedCategory
    }

    func summarize(_ summary: PeriodSummary, monthlyLimit: Double?, currencyCode: String) -> AsyncThrowingStream<String, any Error> {
        replyStream()
    }

    func ask(_ question: String) -> AsyncThrowingStream<String, any Error> {
        replyStream()
    }

    func resetConversation() {}

    /// Cumulative word-by-word prefixes of `reply`, like the real model's snapshots.
    private func replyStream() -> AsyncThrowingStream<String, any Error> {
        let words = reply.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        let delay = delay
        let shouldFail = shouldFail
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await Task.sleep(for: .seconds(delay))
                    if shouldFail { throw IntelligenceError.failed }
                    var text = ""
                    for word in words {
                        text += text.isEmpty ? word : " " + word
                        continuation.yield(text)
                        try await Task.sleep(for: .seconds(delay / 10))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
