//
//  DebugSeeder.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import Foundation
import SwiftData

// MARK: - DebugSeeder

enum DebugSeeder {
    /// Launch arg `-messup_seed_sample_data YES`: replace the store content with sample data at every launch.
    static let forceSeedKey = "messup_seed_sample_data"
    /// Launch arg `-messup_autoseed NO` (or the Settings ▸ Debug toggle): do not seed an empty store.
    static let autoSeedKey = "messup_autoseed"

    /// Called at launch. Forced seeding replaces the data; otherwise an empty store is seeded unless auto-seed is off.
    static func seedOnLaunch(in store: LocalStore, defaults: UserDefaults = .standard) throws {
        if defaults.bool(forKey: forceSeedKey) {
            try replaceWithSampleData(in: store)
            return
        }
        let isAutoSeedOn = defaults.object(forKey: autoSeedKey) == nil || defaults.bool(forKey: autoSeedKey)
        if isAutoSeedOn, try isEmpty(store) {
            try replaceWithSampleData(in: store)
        }
    }

    static func replaceWithSampleData(in store: LocalStore, now: Date = .now) throws {
        try deleteAllData(in: store)
        let sample = SampleDataGenerator.make(now: now)
        let context = store.context
        sample.expenses.forEach { context.insert(ExpenseRecord($0)) }
        sample.incomes.forEach { context.insert(IncomeRecord($0)) }
        sample.contributions.forEach { context.insert(ContributionRecord($0)) }
        context.insert(SavingGoalRecord(sample.goal))
        context.insert(BudgetRecord(sample.budget))
        try context.save()
    }

    static func deleteAllData(in store: LocalStore) throws {
        let context = store.context
        try context.delete(model: ExpenseRecord.self)
        try context.delete(model: IncomeRecord.self)
        try context.delete(model: ContributionRecord.self)
        try context.delete(model: SavingGoalRecord.self)
        try context.delete(model: BudgetRecord.self)
        try context.save()
    }

    static func isEmpty(_ store: LocalStore) throws -> Bool {
        let context = store.context
        return try context.fetchCount(FetchDescriptor<ExpenseRecord>()) == 0
            && context.fetchCount(FetchDescriptor<IncomeRecord>()) == 0
            && context.fetchCount(FetchDescriptor<ContributionRecord>()) == 0
            && context.fetchCount(FetchDescriptor<SavingGoalRecord>()) == 0
            && context.fetchCount(FetchDescriptor<BudgetRecord>()) == 0
    }
}
#endif
