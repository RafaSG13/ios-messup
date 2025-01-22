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
    var category: Category
}

// MARK: - Comparable Conformance

extension Expense: Comparable {
    static func < (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.date < rhs.date
    }
}

// MARK: - Mocks

extension Expense {
    static var mock = Expense(name: "Puma Store", amount: 59.95, date: Date(), paymentMethod: .creditCard, category: .fashion)
    static var mockArray: [Expense] = [
        Expense(name: "Puma Store", amount: 59.95, date: Date(), paymentMethod: .creditCard, category: .fashion),
        Expense(name: "Apple Store", amount: 1299.99, date: Date().addingTimeInterval(-86400), paymentMethod: .creditCard, category: .technology),
        Expense(name: "Grocery Store", amount: 75.49, date: Date().addingTimeInterval(-172800), paymentMethod: .debitCard, category: .food),
        Expense(name: "Coffee Shop", amount: 4.95, date: Date().addingTimeInterval(-3600), paymentMethod: .cash, category: .food),
        Expense(name: "Online Subscription", amount: 12.99, date: Date().addingTimeInterval(-604800), paymentMethod: .creditCard, category: .entertainment),
        Expense(name: "Gym Membership", amount: 45.00, date: Date().addingTimeInterval(-2592000), paymentMethod: .debitCard, category: .health),
        Expense(name: "Gas Station", amount: 50.87, date: Date().addingTimeInterval(-432000), paymentMethod: .creditCard, category: .transportation),
        Expense(name: "Bookstore", amount: 23.45, date: Date().addingTimeInterval(-216000), paymentMethod: .cash, category: .education),
        Expense(name: "Streaming Service", amount: 19.99, date: Date().addingTimeInterval(-1036800), paymentMethod: .creditCard, category: .entertainment),
        Expense(name: "Restaurant", amount: 88.75, date: Date().addingTimeInterval(-864000), paymentMethod: .debitCard, category: .food),
        Expense(name: "Hotel Booking", amount: 399.99, date: Date().addingTimeInterval(-1209600), paymentMethod: .creditCard, category: .travel),
        Expense(name: "Movie Tickets", amount: 28.50, date: Date().addingTimeInterval(-7200), paymentMethod: .cash, category: .entertainment),
        Expense(name: "Electronics Store", amount: 599.99, date: Date().addingTimeInterval(-259200), paymentMethod: .creditCard, category: .technology),
        Expense(name: "Clothing Store", amount: 120.00, date: Date().addingTimeInterval(-1728000), paymentMethod: .debitCard, category: .fashion)
    ]
}
