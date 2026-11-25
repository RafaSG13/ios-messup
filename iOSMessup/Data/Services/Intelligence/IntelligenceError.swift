//
//  IntelligenceError.swift
//  iOSMessup
//

import Foundation
import FoundationModels

enum IntelligenceError: LocalizedError, Equatable {
    case unavailable
    case couldNotUnderstand
    case unreadableImage
    case conversationTooLong
    case unsupportedLanguage
    case refused
    case failed

    var errorDescription: String? {
        switch self {
        case .unavailable:
            String(localized: "Apple Intelligence isn't available right now.")
        case .couldNotUnderstand:
            String(localized: "Couldn't find an expense in that text. Include an amount, like “Coffee 3.50”.")
        case .unreadableImage:
            String(localized: "Couldn't read that image. Try a clearer photo of the receipt.")
        case .conversationTooLong:
            String(localized: "The conversation got too long, so it was restarted. Ask again.")
        case .unsupportedLanguage:
            String(localized: "Apple Intelligence doesn't support this language yet.")
        case .refused:
            String(localized: "Apple Intelligence can't help with that request.")
        case .failed:
            String(localized: "Apple Intelligence couldn't complete the request. Try again.")
        }
    }

    /// Maps Foundation Models errors to ones the UI can explain; anything else is returned unchanged.
    static func wrap(_ error: any Error) -> any Error {
        if error is IntelligenceError || error is CancellationError { return error }
        guard let modelError = error as? LanguageModelError else { return error }
        switch modelError {
        case .contextSizeExceeded: return IntelligenceError.conversationTooLong
        case .guardrailViolation, .refusal: return IntelligenceError.refused
        case .unsupportedLanguageOrLocale: return IntelligenceError.unsupportedLanguage
        default: return IntelligenceError.failed
        }
    }
}
