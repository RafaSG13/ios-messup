//
//  Route.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 27/1/25.
//

import SwiftUI

enum Route: Hashable {
    case transactionList

    @ViewBuilder
    var destination: some View {
        switch self {
        case .transactionList: AllExpensesView()
        }
    }
}
