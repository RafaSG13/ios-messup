//
//  IncomeService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class IncomeService: IncomeServiceProtocol {
    private(set) var incomes: [Income] = []

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func load() async throws {
        try reloadIncomes()
    }

    func createIncome(_ income: Income) async throws {
        let context = store.context
        context.insert(IncomeRecord(income))
        try context.save()
        try reloadIncomes()
    }

    func updateIncome(with newValue: Income) async throws {
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<IncomeRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(newValue)
        try context.save()
        try reloadIncomes()
    }

    func deleteIncome(_ income: Income) async throws {
        let context = store.context
        let id = income.id
        let records = try context.fetch(FetchDescriptor<IncomeRecord>(predicate: #Predicate { $0.id == id }))
        records.forEach { context.delete($0) }
        try context.save()
        try reloadIncomes()
    }

    // MARK: - Persistence

    private func reloadIncomes() throws {
        let descriptor = FetchDescriptor<IncomeRecord>(sortBy: [SortDescriptor(\.date)])
        incomes = try store.context.fetch(descriptor).map(\.domain)
    }

    // MARK: - Derived

    func lastIncomes(limit: Int) -> [Income] {
        Array(incomes.sorted().suffix(limit))
    }

    func filteredIncomes(on searchTerm: String) -> [Income] {
        guard !searchTerm.isEmpty, searchTerm.count > 3 else { return incomes }
        return incomes.filter { $0.concept.localizedCaseInsensitiveContains(searchTerm) }
    }
}
