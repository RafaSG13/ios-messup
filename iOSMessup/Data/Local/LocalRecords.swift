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

// MARK: - BudgetRecord

@Model
final class BudgetRecord {
    @Attribute(.unique) var id: String
    var monthlyLimit: Double
    /// Keyed by `Category.rawValue`.
    var categoryLimitsRaw: [String: Double]

    init(_ budget: Budget) {
        self.id = budget.id
        self.monthlyLimit = budget.monthlyLimit
        self.categoryLimitsRaw = Dictionary(uniqueKeysWithValues: budget.categoryLimits.map { ($0.key.rawValue, $0.value) })
    }

    /// Limits of categories that no longer exist are dropped.
    var domain: Budget {
        var limits: [Category: Double] = [:]
        for (raw, limit) in categoryLimitsRaw {
            if let category = Category(rawValue: raw) { limits[category] = limit }
        }
        return Budget(id: id, monthlyLimit: monthlyLimit, categoryLimits: limits)
    }

    func apply(_ budget: Budget) {
        monthlyLimit = budget.monthlyLimit
        categoryLimitsRaw = Dictionary(uniqueKeysWithValues: budget.categoryLimits.map { ($0.key.rawValue, $0.value) })
    }
}

// MARK: - PersonRecord

@Model
final class PersonRecord {
    @Attribute(.unique) var id: String
    var name: String
    var contactIdentifier: String?

    init(_ person: Person) {
        self.id = person.id
        self.name = person.name
        self.contactIdentifier = person.contactIdentifier
    }

    var domain: Person {
        Person(id: id, name: name, contactIdentifier: contactIdentifier)
    }

    func apply(_ person: Person) {
        name = person.name
        contactIdentifier = person.contactIdentifier
    }
}

// MARK: - DebtEntryRecord

/// Plain record (no SwiftData relationship to `PersonRecord`, like the rest of the store); `DebtsService` removes a
/// person's entries when the person is deleted.
@Model
final class DebtEntryRecord {
    @Attribute(.unique) var id: String
    var personID: String
    var kindRaw: String
    var amount: Double
    var date: Date
    var note: String

    init(_ entry: DebtEntry) {
        self.id = entry.id
        self.personID = entry.personID
        self.kindRaw = entry.kind.rawValue
        self.amount = entry.amount
        self.date = entry.date
        self.note = entry.note
    }

    var domain: DebtEntry {
        DebtEntry(id: id,
                  personID: personID,
                  kind: DebtEntryKind(rawValue: kindRaw) ?? .lent,
                  amount: amount,
                  date: date,
                  note: note)
    }

    func apply(_ entry: DebtEntry) {
        personID = entry.personID
        kindRaw = entry.kind.rawValue
        amount = entry.amount
        date = entry.date
        note = entry.note
    }
}
