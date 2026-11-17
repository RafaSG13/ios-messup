//
//  BudgetService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class BudgetService: BudgetServiceProtocol {
    private(set) var budget: Budget?

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func load() async throws {
        try reload()
    }

    /// Only one budget exists at a time.
    func saveBudget(_ budget: Budget) async throws {
        let context = store.context
        try context.delete(model: BudgetRecord.self)
        context.insert(BudgetRecord(budget))
        try context.save()
        try reload()
    }

    func deleteBudget() async throws {
        let context = store.context
        try context.delete(model: BudgetRecord.self)
        try context.save()
        try reload()
    }

    private func reload() throws {
        var descriptor = FetchDescriptor<BudgetRecord>()
        descriptor.fetchLimit = 1
        budget = try store.context.fetch(descriptor).first?.domain
    }

    // MARK: - Derived

    func progress(spent: Double) -> BudgetProgress? {
        guard let budget else { return nil }
        return BudgetProgress(spent: spent, limit: budget.monthlyLimit)
    }

    func progress(for category: Category, spent: Double) -> BudgetProgress? {
        guard let limit = budget?.categoryLimits[category] else { return nil }
        return BudgetProgress(spent: spent, limit: limit)
    }
}
