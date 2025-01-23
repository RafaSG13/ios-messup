//
//  MainTabBarView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI


enum Tab: Int, CaseIterable {
    case expenses
    case savings
    case socialGroups
}

struct MainTabBarView: View {
    @State var activeTab: Tab = .expenses
    var expenseViewModel = ExpenseViewModel(dataSource: ExpensesDataSource())

    var body: some View {
        TabView(selection: $activeTab) {
            ExpensesView()
                .environment(expenseViewModel )
                .tabItem { Label("Expenses", systemImage: "dollarsign.circle.fill") }
                .tag(Tab.expenses)
            SavingsObjectiveView()
                .tabItem { Label("Savings", systemImage: "chart.pie.fill") }
                .tag(Tab.savings)
            SocialGroupsView()
                .tabItem { Label("Social groups", systemImage: "person.3.fill") }
                .tag(Tab.socialGroups)
        }
        .tint(.black)
        .task {
            do {
                try await expenseViewModel.loadExpenses()
            } catch {
                print("Error loading expenses: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MainTabBarView()
}
