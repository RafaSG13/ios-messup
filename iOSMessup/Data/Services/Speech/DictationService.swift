//
//  DictationService.swift
//  iOSMessup
//

import AVFAudio
import Foundation
import Speech

/// On-device dictation with `SpeechAnalyzer` + `SpeechTranscriber`: the microphone feeds the analyzer through an
/// `AsyncStream`, and the transcriber's results become the cumulative transcript.
final class DictationService: DictationServiceProtocol {
    private struct Session {
        let capture: AudioCapture
        let analyzer: SpeechAnalyzer
        let input: AsyncStream<AnalyzerInput>.Continuation
    }

    private var session: Session?

    func isAvailable() async -> Bool {
        guard SpeechTranscriber.isAvailable else { return false }
        return await SpeechTranscriber.supportedLocale(equivalentTo: .current) != nil
    }

    func start() async throws -> AsyncThrowingStream<String, any Error> {
        await stop()
        guard await AVAudioApplication.requestRecordPermission() else { throw DictationError.microphoneDenied }
        guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: .current) else {
            throw DictationError.unsupportedLanguage
        }

        do {
            let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
            if let installation = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try await installation.downloadAndInstall()
            }
            guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
                throw DictationError.failed
            }

            let (inputSequence, input) = AsyncStream<AnalyzerInput>.makeStream()
            let analyzer = SpeechAnalyzer(inputSequence: inputSequence, modules: [transcriber])
            let capture = AudioCapture()
            try capture.start(converting: format, into: input)
            session = Session(capture: capture, analyzer: analyzer, input: input)

            return AsyncThrowingStream { continuation in
                let task = Task {
                    var finalized = ""
                    do {
                        for try await result in transcriber.results {
                            let text = String(result.text.characters)
                            if result.isFinal {
                                finalized = Self.joined(finalized, text)
                                continuation.yield(finalized)
                            } else {
                                continuation.yield(Self.joined(finalized, text))
                            }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.onTermination = { _ in
                    task.cancel()
                    Task { await self.stop() }
                }
            }
        } catch let error as DictationError {
            await stop()
            throw error
        } catch {
            await stop()
            throw DictationError.failed
        }
    }

    func stop() async {
        guard let session else { return }
        self.session = nil
        session.capture.stop()
        session.input.finish()
        try? await session.analyzer.finalizeAndFinishThroughEndOfInput()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Segments may or may not carry their own spacing.
    private static func joined(_ head: String, _ tail: String) -> String {
        guard !head.isEmpty, !tail.isEmpty else { return head + tail }
        return head.last!.isWhitespace || tail.first!.isWhitespace ? head + tail : head + " " + tail
    }
}

// MARK: - AudioCapture

/// Owns the `AVAudioEngine`. The tap closure runs on the audio thread, so this type is `nonisolated` and the closure
/// touches nothing from the main actor: it converts each buffer and yields it into the analyzer's input stream.
private nonisolated final class AudioCapture: @unchecked Sendable {
    private let engine = AVAudioEngine()

    func start(converting targetFormat: AVAudioFormat, into input: AsyncStream<AnalyzerInput>.Continuation) throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = engine.inputNode
        let sourceFormat = inputNode.outputFormat(forBus: 0)
        let converter = sourceFormat == targetFormat ? nil : AVAudioConverter(from: sourceFormat, to: targetFormat)

        // The iOS 27 `installTap(…error:block:)` has no Swift spelling in the 27.1 SDK yet (only `__installTap`).
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: sourceFormat) { buffer, _ in
            guard let converter else {
                input.yield(AnalyzerInput(buffer: buffer))
                return
            }
            let ratio = targetFormat.sampleRate / sourceFormat.sampleRate
            let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 1
            guard let converted = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }
            nonisolated(unsafe) var isConsumed = false
            var conversionError: NSError?
            converter.convert(to: converted, error: &conversionError) { _, status in
                if isConsumed {
                    status.pointee = .noDataNow
                    return nil
                }
                isConsumed = true
                status.pointee = .haveData
                return buffer
            }
            if conversionError == nil, converted.frameLength > 0 {
                input.yield(AnalyzerInput(buffer: converted))
            }
        }
        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }
}
