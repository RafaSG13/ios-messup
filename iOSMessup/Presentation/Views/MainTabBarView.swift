//
//  MainTabBarView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

enum AppTab: Hashable {
    case expenses
    case income
    case settings
}

struct MainTabBarView: View {
    @State private var activeTab: AppTab = .expenses

    var body: some View {
        TabView(selection: $activeTab) {
            Tab("Expenses", systemImage: "creditcard.fill", value: .expenses) {
                ExpensesView()
            }
            Tab("Income", systemImage: "chart.pie.fill", value: .income) {
                IncomeObjectiveView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    MainTabBarView()
}
