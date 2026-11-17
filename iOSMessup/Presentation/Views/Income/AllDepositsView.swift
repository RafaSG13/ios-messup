//
//  AllDepositsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI
import MUDesignSystem

struct AllDepositsView: View {
    @Environment(\.incomeService) private var incomeService
    @State private var selectedDeposit: Deposit?
    @State private var isAddingDeposit = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        let sections = incomeService.filteredDeposits(on: searchText).groupedByDay(date: \.date)

        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.items) { deposit in
                        DepositCellView(deposit: deposit)
                            .selectableCell { selectedDeposit = deposit }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) { delete(deposit) }
                            }
                    }
                } header: {
                    Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide).year())
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if incomeService.deposits.isEmpty {
                ContentUnavailableView {
                    Label("No deposits", systemImage: "banknote")
                } description: {
                    Text("Deposits you add count toward your saving goal.")
                } actions: {
                    Button("Add deposit") { isAddingDeposit = true }
                        .buttonStyle(.borderedProminent)
                }
            } else if sections.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .searchable(text: $searchText, placement: .toolbar)
        .searchToolbarBehavior(.minimize)
        .navigationTitle("All Deposits")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add deposit", systemImage: "plus") {
                    isAddingDeposit = true
                }
                .buttonStyle(.glassProminent)
            }
        }
        .errorAlert($error)
        .editDepositSheet(deposit: $selectedDeposit) { deposit in
            try await incomeService.updateDeposit(with: deposit)
        }
        .addDepositSheet(isPresented: $isAddingDeposit) { deposit in
            try await incomeService.createDeposit(deposit)
        }
    }
}

// MARK: - Actions

private extension AllDepositsView {
    func delete(_ deposit: Deposit) {
        Task {
            do {
                try await incomeService.deleteDeposit(deposit)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Preview

#Preview("Mock data") {
    NavigationStack {
        AllDepositsView()
    }
}

#Preview("Empty") {
    NavigationStack {
        AllDepositsView()
    }
    .environment(\.incomeService, MockIncomeService(initialDeposits: [], initialGoal: nil, delay: 0))
}

#Preview("Failing service") {
    NavigationStack {
        AllDepositsView()
    }
    .environment(\.incomeService, MockIncomeService(delay: 0, shouldFail: true))
}
