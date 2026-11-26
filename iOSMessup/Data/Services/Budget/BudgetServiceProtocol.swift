//
//  BudgetServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import SwiftUI

protocol BudgetServiceProtocol: AnyObject {
    /// The single budget, `nil` until the user sets one.
    var budget: Budget? { get }

    func load() async throws
    /// Creates the budget or replaces the existing one.
    func saveBudget(_ budget: Budget) async throws
    func deleteBudget() async throws
    /// Progress of the monthly limit for `spent`; `nil` without a budget.
    func progress(spent: Double) -> BudgetProgress?
    /// Progress of the limit of `category`; `nil` when there is no budget or no limit for that category.
    func progress(for category: Category, spent: Double) -> BudgetProgress?
}

extension EnvironmentValues {
    @Entry var budgetService: BudgetServiceProtocol = defaultBudgetService
    // A `static let`: the macro's getter runs on every fallback read, so `MockBudgetService()` there would allocate a new service each time.
    private static let defaultBudgetService = MockBudgetService()
}
