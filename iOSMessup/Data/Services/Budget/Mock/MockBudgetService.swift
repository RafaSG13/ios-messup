//
//  MockBudgetService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class MockBudgetService: BudgetServiceProtocol {
    private(set) var budget: Budget?
    var delay: TimeInterval
    var shouldFail: Bool

    init(initialBudget: Budget? = Budget.mock, delay: TimeInterval = 0.1, shouldFail: Bool = false) {
        self.budget = initialBudget
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

    func saveBudget(_ budget: Budget) async throws {
        try await simulateNetwork()
        self.budget = budget
    }

    func deleteBudget() async throws {
        try await simulateNetwork()
        budget = nil
    }

    func progress(spent: Double) -> BudgetProgress? {
        guard let budget else { return nil }
        return BudgetProgress(spent: spent, limit: budget.monthlyLimit)
    }

    func progress(for category: Category, spent: Double) -> BudgetProgress? {
        guard let limit = budget?.categoryLimits[category] else { return nil }
        return BudgetProgress(spent: spent, limit: limit)
    }
}
