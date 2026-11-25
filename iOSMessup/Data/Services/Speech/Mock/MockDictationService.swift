//
//  MockDictationService.swift
//  iOSMessup
//

import Foundation

final class MockDictationService: DictationServiceProtocol {
    var transcript: String
    var delay: TimeInterval
    var shouldFail: Bool
    private var continuation: AsyncThrowingStream<String, any Error>.Continuation?

    init(transcript: String = "Add a coffee for 3.50", delay: TimeInterval = 0.1, shouldFail: Bool = false) {
        self.transcript = transcript
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func isAvailable() async -> Bool { true }

    /// Yields the transcript word by word (cumulative), then stays open until `stop()`.
    func start() async throws -> AsyncThrowingStream<String, any Error> {
        if shouldFail { throw DictationError.failed }
        let words = transcript.split(separator: " ").map(String.init)
        let delay = delay
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
            let task = Task {
                var text = ""
                for word in words {
                    try? await Task.sleep(for: .seconds(delay))
                    text += text.isEmpty ? word : " " + word
                    continuation.yield(text)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func stop() async {
        continuation?.finish()
        continuation = nil
    }
}
