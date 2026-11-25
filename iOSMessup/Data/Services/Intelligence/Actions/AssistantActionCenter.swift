//
//  AssistantActionCenter.swift
//  iOSMessup
//

import Foundation
import Observation

/// Meeting point between the assistant's change tools and the chat UI: tools announce what they did (`record`) and
/// ask the user before deleting (`confirm`). A deletion tool stays suspended in `confirm` until the user answers.
@Observable
final class AssistantActionCenter {
    struct ConfirmationRequest: Equatable {
        let title: String
        let details: [String]
        let confirmLabel: String
    }

    struct ActionEvent: Identifiable, Equatable {
        let id = UUID()
        let systemImage: String
        let title: String
        let detail: String
    }

    /// The question the chat is showing, if any.
    private(set) var pending: ConfirmationRequest?
    /// The latest thing the assistant changed; the chat observes it to add an activity card.
    private(set) var lastEvent: ActionEvent?

    @ObservationIgnored private var continuation: CheckedContinuation<Bool, Never>?
    @ObservationIgnored private var currentRequestID: UUID?

    /// Suspends until the user answers (`resolve`). A cancelled task and a newer request both resolve it as `false`.
    func confirm(_ request: ConfirmationRequest) async -> Bool {
        resolve(false)
        let requestID = UUID()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                guard !Task.isCancelled else {
                    continuation.resume(returning: false)
                    return
                }
                currentRequestID = requestID
                self.continuation = continuation
                pending = request
            }
        } onCancel: {
            Task { @MainActor [weak self] in self?.cancel(requestID) }
        }
    }

    /// Answers the pending request (the card's buttons). No-op without one.
    func resolve(_ approved: Bool) {
        let continuation = continuation
        self.continuation = nil
        currentRequestID = nil
        pending = nil
        continuation?.resume(returning: approved)
    }

    func record(_ event: ActionEvent) {
        lastEvent = event
    }

    private func cancel(_ requestID: UUID) {
        guard currentRequestID == requestID else { return }
        resolve(false)
    }
}

#if DEBUG
extension AssistantActionCenter {
    /// Shows `request` as pending without a suspended tool, for previews.
    func preview(pending request: ConfirmationRequest) {
        pending = request
    }
}
#endif
