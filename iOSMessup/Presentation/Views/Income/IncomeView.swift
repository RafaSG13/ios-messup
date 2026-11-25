//
//  IncomeView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - IncomeView

/// Owns the screen state (period, search, sheets). Data reads live in the list's sections, so a keystroke in the
/// search field does not rebuild the balance summary.
struct IncomeView: View {
    @Environment(\.incomeService) private var incomeService
    @State private var kind = PeriodKind.month
    @State private var anchor = Date.now
    @State private var selectedIncome: Income?
    @State private var isAddingIncome = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack {
            IncomeList(kind: $kind,
                       anchor: $anchor,
                       searchText: searchText,
                       selectedIncome: $selectedIncome,
                       isAddingIncome: $isAddingIncome,
                       error: $error)
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

// MARK: - IncomeList

private struct IncomeList: View {
    @Environment(\.incomeService) private var incomeService
    @Binding var kind: PeriodKind
    @Binding var anchor: Date
    let searchText: String
    @Binding var selectedIncome: Income?
    @Binding var isAddingIncome: Bool
    @Binding var error: (any Error)?

    var body: some View {
        let hasIncomes = !incomeService.incomes.isEmpty

        List {
            if hasIncomes {
                Section {
                    PeriodPicker(kind: $kind, anchor: $anchor)
                }
                IncomeBalanceSection(kind: kind, anchor: anchor)
                IncomeResultsSections(kind: kind,
                                      anchor: anchor,
                                      searchText: searchText,
                                      selectedIncome: $selectedIncome,
                                      error: $error)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(MUSpacer.size04)
        .overlay {
            if !hasIncomes {
                MUEmptyState("No income",
                             systemImage: "arrow.down.circle",
                             description: "Add your salary, gifts and other money coming in.",
                             actionTitle: "Add income") {
                    isAddingIncome = true
                }
            }
        }
    }
}

// MARK: - IncomeBalanceSection

private struct IncomeBalanceSection: View {
    @Environment(\.incomeService) private var incomeService
    @Environment(\.expenseService) private var expenseService
    @Environment(\.debtsService) private var debtsService
    let kind: PeriodKind
    let anchor: Date

    var body: some View {
        let summary = PeriodSummary(period: Period(kind: kind, containing: anchor),
                                    expenses: expenseService.expenses,
                                    incomes: incomeService.incomes,
                                    debts: debtsService.entries)

        Section {
            BalanceSummaryCard(summary: summary)
                .clearListRow(insets: EdgeInsets())
        }
    }
}

// MARK: - IncomeResultsSections

private struct IncomeResultsSections: View {
    @Environment(\.incomeService) private var incomeService
    let kind: PeriodKind
    let anchor: Date
    let searchText: String
    @Binding var selectedIncome: Income?
    @Binding var error: (any Error)?

    var body: some View {
        let period = Period(kind: kind, containing: anchor)
        let periodHasIncomes = incomeService.incomes.contains { period.contains($0.date) }
        let sections = incomeService.filteredIncomes(on: searchText)
            .filter { period.contains($0.date) }
            .groupedByDay(date: \.date)

        if sections.isEmpty {
            Section {
                if periodHasIncomes {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ContentUnavailableView("No income in this period", systemImage: "arrow.down.circle")
                }
            }
            .clearListRow()
        }
        ForEach(sections) { section in
            Section {
                ForEach(section.items) { income in
                    IncomeListRow(income: income, selectedIncome: $selectedIncome, error: $error)
                }
            } header: {
                Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide).year())
            }
        }
    }
}

// MARK: - IncomeListRow

private struct IncomeListRow: View {
    @Environment(\.incomeService) private var incomeService
    let income: Income
    @Binding var selectedIncome: Income?
    @Binding var error: (any Error)?

    var body: some View {
        IncomeCellView(income: income)
            .selectableCell { selectedIncome = income }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive, action: delete)
            }
    }

    private func delete() {
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
