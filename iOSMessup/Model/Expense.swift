//
//  Expense.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import Foundation

struct Expense: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var amount: Double
    var date: Date
    var paymentMethod: PaymentMethod
}

// MARK: - Comparable Conformance

extension Expense: Comparable {
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.date < rhs.date
    }
}

// MARK: - Mocks

extension Expense {
    static var mock = Expense(name: "Puma Store", amount: 59.95, date: Date(), paymentMethod: .creditCard)
    static var mockArray: [Expense] = [
        Expense(name: "Puma Store", amount: 59.95, date: Date(), paymentMethod: .creditCard),
        Expense(name: "Apple Store", amount: 1299.99, date: Date().addingTimeInterval(-86400), paymentMethod: .creditCard),
        Expense(name: "Grocery Store", amount: 75.49, date: Date().addingTimeInterval(-172800), paymentMethod: .debitCard),
        Expense(name: "Coffee Shop", amount: 4.95, date: Date().addingTimeInterval(-3600), paymentMethod: .cash),
        Expense(name: "Online Subscription", amount: 12.99, date: Date().addingTimeInterval(-604800), paymentMethod: .creditCard),
        Expense(name: "Gym Membership", amount: 45.00, date: Date().addingTimeInterval(-2592000), paymentMethod: .debitCard),
        Expense(name: "Gas Station", amount: 50.87, date: Date().addingTimeInterval(-432000), paymentMethod: .creditCard),
        Expense(name: "Bookstore", amount: 23.45, date: Date().addingTimeInterval(-216000), paymentMethod: .cash),
        Expense(name: "Streaming Service", amount: 19.99, date: Date().addingTimeInterval(-1036800), paymentMethod: .creditCard),
        Expense(name: "Restaurant", amount: 88.75, date: Date().addingTimeInterval(-864000), paymentMethod: .debitCard),
        Expense(name: "Hotel Booking", amount: 399.99, date: Date().addingTimeInterval(-1209600), paymentMethod: .creditCard),
        Expense(name: "Movie Tickets", amount: 28.50, date: Date().addingTimeInterval(-7200), paymentMethod: .cash),
        Expense(name: "Electronics Store", amount: 599.99, date: Date().addingTimeInterval(-259200), paymentMethod: .creditCard),
        Expense(name: "Clothing Store", amount: 120.00, date: Date().addingTimeInterval(-1728000), paymentMethod: .debitCard)
    ]
}
