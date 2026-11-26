//
//  DictationServiceProtocol.swift
//  iOSMessup
//

import Foundation
import SwiftUI

/// Speech to text, transcribed on the device (Speech framework). It only fills the text field: the user reviews
/// the text and sends it.
protocol DictationServiceProtocol: AnyObject {
    /// The current language can be transcribed on this device.
    func isAvailable() async -> Bool
    /// Starts listening and yields the whole transcript so far (finalized plus tentative text), not deltas. The stream
    /// ends after `stop()` or when the consumer stops iterating. Asks for microphone permission the first time.
    func start() async throws -> AsyncThrowingStream<String, any Error>
    /// Stops listening; the transcript stream finishes once the last words are transcribed.
    func stop() async
}

enum DictationError: LocalizedError, Equatable {
    case microphoneDenied
    case unsupportedLanguage
    case failed

    var errorDescription: String? {
        switch self {
        case .microphoneDenied: String(localized: "Microphone access is off. Turn it on in Settings ▸ Messup.")
        case .unsupportedLanguage: String(localized: "Dictation doesn't support this language yet.")
        case .failed: String(localized: "Dictation couldn't start. Try again.")
        }
    }
}

extension EnvironmentValues {
    @Entry var dictationService: DictationServiceProtocol = defaultDictationService
    // A `static let`: the macro's getter runs on every fallback read, so `MockDictationService()` there would allocate a new service each time.
    private static let defaultDictationService = MockDictationService()
}
