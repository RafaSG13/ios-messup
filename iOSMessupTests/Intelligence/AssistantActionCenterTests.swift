//
//  AssistantActionCenterTests.swift
//  iOSMessupTests
//

import Foundation
import Testing
@testable import iOSMessup

struct AssistantActionCenterTests {
    private let request = AssistantActionCenter.ConfirmationRequest(title: "Delete expense?",
                                                                    details: ["Coffee"],
                                                                    confirmLabel: "Delete")

    /// Lets the suspended `confirm` publish its request.
    private func waitUntilPending(_ center: AssistantActionCenter) async {
        while center.pending == nil { await Task.yield() }
    }

    @Test func confirmWaitsForTheUserAndReturnsTheAnswer() async {
        let center = AssistantActionCenter()
        let task = Task { await center.confirm(request) }

        await waitUntilPending(center)
        #expect(center.pending == request)
        center.resolve(true)

        #expect(await task.value == true)
        #expect(center.pending == nil)
    }

    @Test func decliningReturnsFalse() async {
        let center = AssistantActionCenter()
        let task = Task { await center.confirm(request) }

        await waitUntilPending(center)
        center.resolve(false)

        #expect(await task.value == false)
        #expect(center.pending == nil)
    }

    @Test func cancellingTheWaitingTaskResolvesFalse() async {
        let center = AssistantActionCenter()
        let task = Task { await center.confirm(request) }

        await waitUntilPending(center)
        task.cancel()

        #expect(await task.value == false)
        #expect(center.pending == nil)
    }

    @Test func aNewRequestResolvesThePreviousOneAsFalse() async {
        let center = AssistantActionCenter()
        let first = Task { await center.confirm(request) }
        await waitUntilPending(center)
        let other = AssistantActionCenter.ConfirmationRequest(title: "Delete income?", details: [], confirmLabel: "Delete")

        let second = Task { await center.confirm(other) }
        #expect(await first.value == false)
        await waitUntilPending(center)
        #expect(center.pending == other)
        center.resolve(true)

        #expect(await second.value == true)
    }

    @Test func resolveWithoutARequestDoesNothing() {
        let center = AssistantActionCenter()

        center.resolve(true)

        #expect(center.pending == nil)
    }

    @Test func recordPublishesTheLatestEvent() {
        let center = AssistantActionCenter()
        let event = AssistantActionCenter.ActionEvent(systemImage: "plus.circle", title: "Created expense", detail: "Coffee")

        center.record(event)

        #expect(center.lastEvent == event)
    }
}
