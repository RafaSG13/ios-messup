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
    case savings
    case settings
}

struct MainTabBarView: View {
    @State private var activeTab: AppTab = .expenses

    var body: some View {
        TabView(selection: $activeTab) {
            Tab("Expenses", systemImage: "creditcard.fill", value: .expenses) {
                ExpensesView()
            }
            Tab("Income", systemImage: "arrow.down.circle.fill", value: .income) {
                IncomeView()
            }
            Tab("Savings", systemImage: "target", value: .savings) {
                SavingsView()
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
