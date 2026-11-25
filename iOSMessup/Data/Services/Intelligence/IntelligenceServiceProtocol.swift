//
//  IntelligenceServiceProtocol.swift
//  iOSMessup
//

import CoreGraphics
import Foundation
import SwiftUI

enum IntelligenceAvailability: Equatable {
    case available
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unsupportedLanguage
}

/// On-device generative features (Apple Foundation Models). Nothing leaves the device.
protocol IntelligenceServiceProtocol: AnyObject {
    var availability: IntelligenceAvailability { get }
    /// The on-device model accepts images (receipt reading).
    var canReadImages: Bool { get }

    func draftExpense(from text: String) async throws -> ExpenseDraft
    func draftExpense(fromReceipt image: CGImage) async throws -> ExpenseDraft
    func suggestCategory(forExpenseNamed name: String) async throws -> Category
    /// Yields the whole text generated so far (cumulative), not deltas.
    func summarize(_ summary: PeriodSummary, monthlyLimit: Double?, currencyCode: String) -> AsyncThrowingStream<String, any Error>
    /// Same cumulative contract; keeps the conversation until `resetConversation()`.
    func ask(_ question: String) -> AsyncThrowingStream<String, any Error>
    func resetConversation()
}

extension EnvironmentValues {
    @Entry var intelligenceService: IntelligenceServiceProtocol = MockIntelligenceService()
}
