//
//  GeneratedMapping.swift
//  iOSMessup
//

import Foundation

extension Category {
    init(_ generated: GeneratedCategory) {
        switch generated {
        case .entertainment: self = .entertainment
        case .travel: self = .travel
        case .food: self = .food
        case .transportation: self = .transportation
        case .health: self = .health
        case .home: self = .home
        case .technology: self = .technology
        case .fashion: self = .fashion
        case .education: self = .education
        case .family: self = .family
        case .finance: self = .finance
        case .taxes: self = .taxes
        case .charity: self = .charity
        case .miscellaneous: self = .miscellaneous
        }
    }
}

extension PaymentMethod {
    init(_ generated: GeneratedPaymentMethod) {
        switch generated {
        case .cash: self = .cash
        case .creditCard: self = .creditCard
        case .debitCard: self = .debitCard
        case .paypal: self = .paypal
        case .other: self = .other
        }
    }
}

extension ExpenseDraft {
    /// An explicit `yyyy-MM-dd` date wins over `daysAgo`; a date that cannot be read falls back to `daysAgo`.
    init(_ generated: GeneratedExpense, now: Date, calendar: Calendar) {
        let name = generated.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let explicitDate = generated.date.flatMap {
            try? Date($0, strategy: Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
        }
        let relativeDate = generated.daysAgo.flatMap { calendar.date(byAdding: .day, value: -$0, to: now) }

        self.init(name: name.isEmpty ? nil : name,
                  amount: generated.amount.flatMap { $0 > 0 ? $0 : nil },
                  date: explicitDate ?? relativeDate,
                  paymentMethod: generated.paymentMethod.map(PaymentMethod.init),
                  category: generated.category.map(Category.init))
    }
}
