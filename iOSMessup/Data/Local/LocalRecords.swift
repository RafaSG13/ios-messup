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

// MARK: - IncomeRecord

@Model
final class IncomeRecord {
    @Attribute(.unique) var id: String
    var concept: String
    var amount: Double
    var date: Date
    var sourceRaw: String

    init(_ income: Income) {
        self.id = income.id
        self.concept = income.concept
        self.amount = income.amount
        self.date = income.date
        self.sourceRaw = income.source.rawValue
    }

    var domain: Income {
        Income(id: id,
               concept: concept,
               amount: amount,
               date: date,
               source: IncomeSource(rawValue: sourceRaw) ?? .other)
    }

    func apply(_ income: Income) {
        concept = income.concept
        amount = income.amount
        date = income.date
        sourceRaw = income.source.rawValue
    }
}

// MARK: - ContributionRecord

@Model
final class ContributionRecord {
    @Attribute(.unique) var id: String
    var amount: Double
    var date: Date
    var note: String

    init(_ contribution: Contribution) {
        self.id = contribution.id
        self.amount = contribution.amount
        self.date = contribution.date
        self.note = contribution.note
    }

    var domain: Contribution {
        Contribution(id: id, amount: amount, date: date, note: note)
    }

    func apply(_ contribution: Contribution) {
        amount = contribution.amount
        date = contribution.date
        note = contribution.note
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
