//
//  Route.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 27/1/25.
//

import SwiftUI

enum Route: Hashable {
    case transactionList
}

// MARK: - RouteDestinationView

struct RouteDestinationView: View {
    let route: Route

    var body: some View {
        switch route {
        case .transactionList: AllExpensesView()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RouteDestinationView(route: .transactionList)
    }
}
