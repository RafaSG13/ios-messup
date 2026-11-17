//
//  IncomeView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

struct IncomeView: View {
    @Environment(\.incomeService) private var incomeService
    @State private var selectedIncome: Income?
    @State private var isAddingIncome = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        let sections = incomeService.filteredIncomes(on: searchText).groupedByDay(date: \.date)

        NavigationStack {
            List {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.items) { income in
                            IncomeCellView(income: income)
                                .selectableCell { selectedIncome = income }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Delete", role: .destructive) { delete(income) }
                                }
                        }
                    } header: {
                        Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if incomeService.incomes.isEmpty {
                    ContentUnavailableView {
                        Label("No income", systemImage: "arrow.down.circle")
                    } description: {
                        Text("Add your salary, gifts and other money coming in.")
                    } actions: {
                        Button("Add income") { isAddingIncome = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else if sections.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, placement: .toolbar)
            .searchToolbarBehavior(.minimize)
            .navigationTitle("Income")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add income", systemImage: "plus") {
                        isAddingIncome = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .errorAlert($error)
            .editIncomeSheet(income: $selectedIncome) { income in
                try await incomeService.updateIncome(with: income)
            }
            .addIncomeSheet(isPresented: $isAddingIncome) { income in
                try await incomeService.createIncome(income)
            }
        }
    }
}

// MARK: - Actions

private extension IncomeView {
    func delete(_ income: Income) {
        Task {
            do {
                try await incomeService.deleteIncome(income)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Preview

#Preview("Mock data") {
    IncomeView()
}

#Preview("Empty") {
    IncomeView()
        .environment(\.incomeService, MockIncomeService(initialIncomes: [], delay: 0))
}

#Preview("Failing service") {
    IncomeView()
        .environment(\.incomeService, MockIncomeService(delay: 0, shouldFail: true))
}
