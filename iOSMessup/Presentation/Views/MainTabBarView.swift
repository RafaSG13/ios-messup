//
//  MainTabBarView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI


enum Tab: Int, CaseIterable {
    case expenses
    case income
    case socialGroups
    case profile
}

struct MainTabBarView: View {
    @State private var activeTab: Tab = .expenses
    var body: some View {
        TabView(selection: $activeTab) {
            ExpensesView()
                .tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill") }
                .tag(Tab.expenses)
            IncomeObjectiveView()
                .tabItem { Label("Income", systemImage: "chart.pie.fill") }
                .tag(Tab.income)
            SocialGroupsView()
                .tabItem { Label("Social groups", systemImage: "bubble.left.and.bubble.right") }
                .tag(Tab.socialGroups)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(Tab.profile)
        }.resettable(selection: $activeTab, firstTabTag: .expenses)
    }
}

#Preview {
    MainTabBarView()
}
