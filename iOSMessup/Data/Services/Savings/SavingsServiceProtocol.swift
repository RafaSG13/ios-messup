//
//  SavingsServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import SwiftUI

/// The saving goal (there is only one for now) and the contributions that fund it.
protocol SavingsServiceProtocol: AnyObject {
    var savingGoal: SavingGoal? { get }
    var contributions: [Contribution] { get }

    func load() async throws
    func createSavingGoal(_ goal: SavingGoal) async throws
    func updateSavingGoal(with newValue: SavingGoal) async throws
    func deleteSavingGoal() async throws
    func addContribution(_ contribution: Contribution) async throws
    func updateContribution(with newValue: Contribution) async throws
    func deleteContribution(_ contribution: Contribution) async throws
    func lastContributions(limit: Int) -> [Contribution]
    /// Sum of all contributions.
    func totalContributed() -> Double
    /// `nil` when there is no goal.
    func progress() -> SavingGoalProgress?
}

extension EnvironmentValues {
    @Entry var savingsService: SavingsServiceProtocol = MockSavingsService()
}
