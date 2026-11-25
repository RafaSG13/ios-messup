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

extension IncomeSource {
    init(_ generated: GeneratedIncomeSource) {
        switch generated {
        case .salary: self = .salary
        case .freelance: self = .freelance
        case .investments: self = .investments
        case .rentalIncome: self = .rentalIncome
        case .businessProfits: self = .businessProfits
        case .gifts: self = .gifts
        case .inheritance: self = .inheritance
        case .bonuses: self = .bonuses
        case .taxRefund: self = .taxRefund
        case .passiveIncome: self = .passiveIncome
        case .sellingAssets: self = .sellingAssets
        case .sideHustle: self = .sideHustle
        case .governmentBenefits: self = .governmentBenefits
        case .other: self = .other
        }
    }
}

extension DebtEntryKind {
    init(_ generated: GeneratedDebtKind) {
        switch generated {
        case .lent: self = .lent
        case .borrowed: self = .borrowed
        case .receivedPayment: self = .receivedPayment
        case .madePayment: self = .madePayment
        }
    }
}

extension Date {
    /// An explicit `yyyy-MM-dd` date wins over `daysAgo`; a date that cannot be read falls back to `daysAgo`;
    /// `nil` when neither is usable.
    static func resolved(explicit: String?, daysAgo: Int?, now: Date, calendar: Calendar) -> Date? {
        let explicitDate = explicit.flatMap {
            try? Date($0, strategy: Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
        }
        let relativeDate = daysAgo.flatMap { calendar.date(byAdding: .day, value: -$0, to: now) }
        return explicitDate ?? relativeDate
    }
}

extension ExpenseDraft {
    init(_ generated: GeneratedExpense, now: Date, calendar: Calendar) {
        let name = generated.name.trimmingCharacters(in: .whitespacesAndNewlines)

        self.init(name: name.isEmpty ? nil : name,
                  amount: generated.amount.flatMap { $0 > 0 ? $0 : nil },
                  date: Date.resolved(explicit: generated.date, daysAgo: generated.daysAgo, now: now, calendar: calendar),
                  paymentMethod: generated.paymentMethod.map(PaymentMethod.init),
                  category: generated.category.map(Category.init))
    }
}
