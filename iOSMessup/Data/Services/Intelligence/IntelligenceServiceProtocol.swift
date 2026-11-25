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

extension IntelligenceAvailability {
    /// What the user sees for this state (Settings status row and the assistant tab).
    var statusText: LocalizedStringKey {
        switch self {
        case .available: "On"
        case .appleIntelligenceNotEnabled: "Off. Turn it on in Settings ▸ Apple Intelligence & Siri"
        case .deviceNotEligible: "Not supported on this device"
        case .modelNotReady: "Getting ready…"
        case .unsupportedLanguage: "Language not supported"
        }
    }
}

/// On-device generative features (Apple Foundation Models). Nothing leaves the device.
protocol IntelligenceServiceProtocol: AnyObject {
    var availability: IntelligenceAvailability { get }
    /// The on-device model accepts images (receipt reading).
    var canReadImages: Bool { get }
    /// Where the assistant's change tools report what they did and ask before deleting.
    var actionCenter: AssistantActionCenter { get }

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
