//
//  Route.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 27/1/25.
//

import SwiftUI

enum Route {
    case depositList
    case transactionList

    @ViewBuilder
    var destination: some View {
        switch self {
        case .depositList: AllDepositsView()
        case .transactionList: AllExpensesView()
        }
    }
}
