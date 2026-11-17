//
//  MockSavingsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class MockSavingsService: SavingsServiceProtocol {
    private(set) var savingGoal: SavingGoal?
    private(set) var contributions: [Contribution]
    var delay: TimeInterval
    var shouldFail: Bool

    init(initialGoal: SavingGoal? = SavingGoal.mock,
         initialContributions: [Contribution] = Contribution.mockArray,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.savingGoal = initialGoal
        self.contributions = initialContributions
        self.delay = delay
        self.shouldFail = shouldFail
    }

    private func simulateNetwork() async throws {
        try await Task.sleep(for: .seconds(delay))
        if shouldFail {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])
        }
    }

    func load() async throws {
        try await simulateNetwork()
    }

    func createSavingGoal(_ goal: SavingGoal) async throws {
        try await simulateNetwork()
        savingGoal = goal
    }

    func updateSavingGoal(with newValue: SavingGoal) async throws {
        try await simulateNetwork()
        savingGoal = newValue
    }

    func deleteSavingGoal() async throws {
        try await simulateNetwork()
        savingGoal = nil
    }

    func addContribution(_ contribution: Contribution) async throws {
        try await simulateNetwork()
        contributions.append(contribution)
    }

    func updateContribution(with newValue: Contribution) async throws {
        try await simulateNetwork()
        if let index = contributions.firstIndex(where: { $0.id == newValue.id }) {
            contributions[index] = newValue
        }
    }

    func deleteContribution(_ contribution: Contribution) async throws {
        try await simulateNetwork()
        contributions.removeAll(where: { $0.id == contribution.id })
    }

    func lastContributions(limit: Int) -> [Contribution] {
        Array(contributions.sorted().suffix(limit))
    }

    func totalContributed() -> Double {
        contributions.reduce(0) { $0 + $1.amount }
    }

    func progress() -> SavingGoalProgress? {
        guard let savingGoal else { return nil }
        return SavingGoalProgress(earned: totalContributed(), target: savingGoal.amount)
    }
}
