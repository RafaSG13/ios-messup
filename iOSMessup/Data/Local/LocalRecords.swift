//
//  LocalRecords.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import SwiftData

// MARK: - ExpenseRecord

@Model
final class ExpenseRecord {
    @Attribute(.unique) var id: String
    var name: String
    var amount: Double
    var date: Date
    var paymentMethodRaw: String
    var categoryRaw: String

    init(_ expense: Expense) {
        self.id = expense.id
        self.name = expense.name
        self.amount = expense.amount
        self.date = expense.date
        self.paymentMethodRaw = expense.paymentMethod.rawValue
        self.categoryRaw = expense.category.rawValue
    }

    var domain: Expense {
        Expense(id: id,
                name: name,
                amount: amount,
                date: date,
                paymentMethod: PaymentMethod(rawValue: paymentMethodRaw) ?? .other,
                category: Category(rawValue: categoryRaw) ?? .miscellaneous)
    }

    func apply(_ expense: Expense) {
        name = expense.name
        amount = expense.amount
        date = expense.date
        paymentMethodRaw = expense.paymentMethod.rawValue
        categoryRaw = expense.category.rawValue
    }
}

// MARK: - DepositRecord

@Model
final class DepositRecord {
    @Attribute(.unique) var id: String
    var concept: String
    var amount: Double
    var date: Date
    var foundingSourceRaw: String

    init(_ deposit: Deposit) {
        self.id = deposit.id
        self.concept = deposit.concept
        self.amount = deposit.amount
        self.date = deposit.date
        self.foundingSourceRaw = deposit.foundingSource.rawValue
    }

    var domain: Deposit {
        Deposit(id: id,
                concept: concept,
                amount: amount,
                date: date,
                foundingSource: FoundingSource(rawValue: foundingSourceRaw) ?? .other)
    }

    func apply(_ deposit: Deposit) {
        concept = deposit.concept
        amount = deposit.amount
        date = deposit.date
        foundingSourceRaw = deposit.foundingSource.rawValue
    }
}

// MARK: - SavingGoalRecord

@Model
final class SavingGoalRecord {
    @Attribute(.unique) var id: String
    var name: String
    var amount: Double
    /// `nil` means `CompletionDate.undefined`.
    var completionDate: Date?
    var savingCategoryRaw: String

    init(_ goal: SavingGoal) {
        self.id = goal.id
        self.name = goal.name
        self.amount = goal.amount
        switch goal.completionDate {
        case .undefined: self.completionDate = nil
        case .fixed(let date): self.completionDate = date
        }
        self.savingCategoryRaw = goal.savingCategory.rawValue
    }

    var domain: SavingGoal {
        SavingGoal(id: id,
                   name: name,
                   completionDate: completionDate.map { .fixed($0) } ?? .undefined,
                   amount: amount,
                   savingCategory: SavingCategory(rawValue: savingCategoryRaw) ?? .liquidity)
    }
}
