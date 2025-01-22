//
//  MainTabBarView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI


enum Tab: Int, CaseIterable {
    case expenses
    case monthlyObjective
    case socialGroups
    case pendingPayments
}

struct MainTabBarView: View {
    @State var activeTab: Tab = .expenses
    var body: some View {
        TabView(selection: $activeTab) {
            ExpensesView()
                .tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill") }
                .tag(Tab.expenses)
            MonthlyObjetiveView()
                .tabItem { Label("Monthly objetive", systemImage: "chart.pie.fill") }
                .tag(Tab.monthlyObjective)
            SocialGroupsView()
                .tabItem { Label("Social groups", systemImage: "person.3.fill") }
                .tag(Tab.socialGroups)
            PendingPaymentsView()
                .tabItem { Label("Pending payments", systemImage: "clock.fill") }
                .tag(Tab.pendingPayments)
        }
    }
}

#Preview {
    MainTabBarView()
}
