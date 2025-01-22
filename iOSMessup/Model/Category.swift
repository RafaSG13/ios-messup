//
//  Category.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

enum Category: String, CaseIterable {
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

    var symbol: String {
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
