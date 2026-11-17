//
//  DebugSeeder.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import Foundation
import SwiftData

enum DebugSeeder {
    @MainActor
    static func replaceWithSampleData(in store: LocalStore) throws {
        try deleteAllData(in: store)
        let context = store.context
        Expense.mockArray.forEach { context.insert(ExpenseRecord($0)) }
        Deposit.mockArray.forEach { context.insert(DepositRecord($0)) }
        context.insert(SavingGoalRecord(SavingGoal.mock))
        try context.save()
    }

    @MainActor
    static func deleteAllData(in store: LocalStore) throws {
        let context = store.context
        try context.delete(model: ExpenseRecord.self)
        try context.delete(model: DepositRecord.self)
        try context.delete(model: SavingGoalRecord.self)
        try context.save()
    }
}
#endif
