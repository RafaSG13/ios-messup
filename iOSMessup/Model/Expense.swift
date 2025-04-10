//
//  Expense.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI

struct Expense: Identifiable, Hashable, Equatable, Codable {
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
        Expense(name: "Apple Store", amount: 329.99, date: Date().addingTimeInterval(-86400), paymentMethod: .creditCard, category: .technology),
        Expense(name: "Grocery Store", amount: 75.49, date: Date().addingTimeInterval(-172800), paymentMethod: .debitCard, category: .food),
        Expense(name: "Gym Membership", amount: 45.00, date: Date().addingTimeInterval(-2592000), paymentMethod: .debitCard, category: .health),
        Expense(name: "Gas Station", amount: 50.87, date: Date().addingTimeInterval(-432000), paymentMethod: .creditCard, category: .transportation),
        Expense(name: "Bookstore", amount: 23.45, date: Date().addingTimeInterval(-216000), paymentMethod: .cash, category: .education),
        Expense(name: "Streaming Service", amount: 19.99, date: Date().addingTimeInterval(-1036800), paymentMethod: .creditCard, category: .entertainment),
        Expense(name: "Restaurant", amount: 88.75, date: Date().addingTimeInterval(-864000), paymentMethod: .debitCard, category: .food),
        Expense(name: "Hotel Booking", amount: 399.99, date: Date().addingTimeInterval(-1209600), paymentMethod: .creditCard, category: .travel),
        Expense(name: "Movie Tickets", amount: 28.50, date: Date().addingTimeInterval(-7200), paymentMethod: .cash, category: .entertainment),
        Expense(name: "Clothing Store", amount: 120.00, date: Date().addingTimeInterval(-1728000), paymentMethod: .debitCard, category: .fashion)
    ]
}

// MARK: - PaymentMethods

enum PaymentMethod: String, CaseIterable, Hashable, Codable {
    case cash = "Cash"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case paypal = "Paypal"
    case other = "Other"

    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .creditCard: return "creditcard.fill"
        case .debitCard: return "creditcard"
        case .paypal: return "cart.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .cash: return .green
        case .creditCard: return .blue
        case .debitCard: return .purple
        case .paypal: return .teal
        case .other: return .gray
        }
    }
}

// MARK: - Expense Categories

enum Category: String, CaseIterable, Hashable, Codable {
    case entertainment = "Entertainment"
    case travel = "Travel"
    case food = "Food"
    case transportation = "Transportation"
    case health = "Health and Wellness"
    case home = "Home"
    case technology = "Technology and Communications"
    case fashion = "Fashion and Beauty"
    case education = "Education and Learning"
    case family = "Family and Pets"
    case finance = "Finance and Insurance"
    case taxes = "Taxes and Obligations"
    case charity = "Donations and Charity"
    case miscellaneous = "Miscellaneous"

    var icon: String {
        switch self {
        case .entertainment: return "film"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .transportation: return "car"
        case .health: return "heart"
        case .home: return "house"
        case .technology: return "desktopcomputer"
        case .fashion: return "tshirt"
        case .education: return "book"
        case .family: return "person.2"
        case .finance: return "creditcard"
        case .taxes: return "doc.text"
        case .charity: return "hands.sparkles"
        case .miscellaneous: return "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .entertainment: return .purple
        case .travel: return .blue
        case .food: return .orange
        case .transportation: return .gray
        case .health: return .red
        case .home: return .green
        case .technology: return .teal
        case .fashion: return .pink
        case .education: return .yellow
        case .family: return .indigo
        case .finance: return .cyan
        case .taxes: return .brown
        case .charity: return .mint
        case .miscellaneous: return .secondary
        }
    }
}


struct ExpenseResponse: Decodable {
    let id: String
    let name: String
    let amount: Double
    let date: Date
    let paymentMethod: String
    let category: String

    func map() -> Expense {
        return Expense(
            id: id,
            name: name,
            amount: amount,
            date: date,
            paymentMethod: PaymentMethod(rawValue: paymentMethod) ?? .other,
            category: Category(rawValue: category) ?? .miscellaneous
        )
    }
}
