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
    case socialGroups
    case profile
}

struct MainTabBarView: View {
    @State private var activeTab: AppTab = .expenses

    var body: some View {
        TabView(selection: $activeTab) {
            Tab("Expenses", systemImage: "dollarsign.circle.fill", value: .expenses) {
                ExpensesView()
            }
            Tab("Income", systemImage: "chart.pie.fill", value: .income) {
                IncomeObjectiveView()
            }
            Tab("Social groups", systemImage: "bubble.left.and.bubble.right", value: .socialGroups) {
                SocialGroupsView()
            }
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabBarView()
}
