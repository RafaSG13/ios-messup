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
    case assistant
    case social
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
            Tab("Assistant", systemImage: "sparkles", value: .assistant) {
                AssistantView()
            }
            Tab("Social", systemImage: "person.2.fill", value: .social) {
                SocialView()
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
