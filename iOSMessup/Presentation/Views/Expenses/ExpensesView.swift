//
//  ExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpensesView

struct ExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.incomeService) private var incomeService
    @Environment(\.savingsService) private var savingsService
    @Environment(\.budgetService) private var budgetService
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var kind = PeriodKind.month
    @State private var anchor = Date.now
    @State private var shouldPresentAddExpense = false
    @State private var isPresentingBudget = false
    @State private var isPresentingAssistant = false
    @State private var selectedItem: Expense?
    @State private var error: (any Error)?

    private enum Constants {
        static let maximumNumberOfExpenses = 6
        static let maximumNumberOfCategories = 5
    }

    var body: some View {
        let period = Period(kind: kind, containing: anchor)
        let summary = PeriodSummary(period: period,
                                    expenses: expenseService.expenses,
                                    incomes: incomeService.incomes,
                                    contributions: savingsService.contributions)

        NavigationStack {
            List {
                if expenseService.expenses.isEmpty {
                    emptyState
                } else {
                    summarySection(summary)
                    insightsSection(summary)
                    categoriesSection(summary)
                    recentSection(period)
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(MUSpacer.size04)
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { $0.destination }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add expense", systemImage: "plus") {
                        shouldPresentAddExpense = true
                    }
                    .buttonStyle(.glassProminent)
                }
                if intelligenceService.availability == .available {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Ask Messup", systemImage: "sparkles") {
                            isPresentingAssistant = true
                        }
                    }
                }
            }
            .errorAlert($error)
            .addExpenseSheet(isPresented: $shouldPresentAddExpense,
                             onSubmit: expenseService.addExpense)
            .editExpenseSheet(item: $selectedItem,
                              onSubmit: expenseService.updateExpense(with:))
            .sheet(isPresented: $isPresentingBudget) {
                BudgetFormView()
            }
            .sheet(isPresented: $isPresentingAssistant) {
                AssistantView()
            }
        }
    }
}

// MARK: - View Components

private extension ExpensesView {
    var emptyState: some View {
        ContentUnavailableView {
            Label("No transactions", systemImage: "creditcard")
        } description: {
            Text("Add your first expense to see your spending here.")
        } actions: {
            Button("Add expense") { shouldPresentAddExpense = true }
                .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    func summarySection(_ summary: PeriodSummary) -> some View {
        Section {
            PeriodPicker(kind: $kind, anchor: $anchor)
        }

        Section {
            ExpensesSummaryCard(summary: summary,
                                showsBudget: kind == .month,
                                budgetProgress: kind == .month ? budgetService.progress(spent: summary.spent) : nil,
                                onEditBudget: { isPresentingBudget = true })
                .cardRow()
        }

        Section {
            MUCard("Spending") {
                CumulativeSpendingChart(summary: summary, monthlyLimit: monthlyLimit)
            }
            .cardRow()
        }
    }

    @ViewBuilder
    func insightsSection(_ summary: PeriodSummary) -> some View {
        let insights = Insight.make(from: summary, monthlyLimit: monthlyLimit)
        if !insights.isEmpty {
            Section {
                ExpenseInsightsCard(insights: insights, summary: summary, monthlyLimit: monthlyLimit)
                    .cardRow()
            }
        }
    }

    func categoriesSection(_ summary: PeriodSummary) -> some View {
        Section {
            MUCard("Categories") {
                if summary.categoryTotals.isEmpty {
                    Text("No expenses in this period.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    CategoryBreakdownView(totals: summary.categoryTotals,
                                          limit: Constants.maximumNumberOfCategories) { category in
                        categoryLimitProgress(for: category, in: summary)
                    }
                }
            }
            .cardRow()
        }
    }

    func recentSection(_ period: Period) -> some View {
        let recent = recentExpenses(in: period)
        return Section {
            if recent.isEmpty {
                Text("No expenses in this period")
                    .foregroundStyle(.secondary)
            }
            ForEach(recent) { expense in
                ExpenseCellView(expense: expense)
                    .selectableCell { selectedItem = expense }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Delete", role: .destructive) { delete(expense) }
                    }
            }
        } header: {
            ListSectionHeaderView(sectionTitle: "Transactions",
                                  actionTitle: "View all",
                                  value: Route.transactionList)
            .textCase(nil)
        }
    }
}

private extension View {
    /// Full-width card on the grouped list background.
    func cardRow() -> some View {
        listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}

// MARK: - Data

private extension ExpensesView {
    /// The overall limit, only meaningful for months.
    var monthlyLimit: Double? {
        kind == .month ? budgetService.budget?.monthlyLimit : nil
    }

    func categoryLimitProgress(for category: Category, in summary: PeriodSummary) -> BudgetProgress? {
        guard kind == .month,
              let spent = summary.categoryTotals.first(where: { $0.category == category })?.amount else { return nil }
        return budgetService.progress(for: category, spent: spent)
    }

    /// The newest expenses of the period, most recent first.
    func recentExpenses(in period: Period) -> [Expense] {
        let inPeriod = expenseService.expenses.filter { period.contains($0.date) }
        return Array(inPeriod.sorted().suffix(Constants.maximumNumberOfExpenses).reversed())
    }

    func delete(_ expense: Expense) {
        Task {
            do {
                try await expenseService.delete(expense)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Previews

#Preview("Mock data") {
    ExpensesView()
}

#Preview("No budget") {
    ExpensesView()
        .environment(\.budgetService, MockBudgetService(initialBudget: nil, delay: 0))
}

#Preview("Empty") {
    ExpensesView()
        .environment(\.expenseService, MockExpensesService(initialExpenses: [], delay: 0))
}

#Preview("Failing service") {
    ExpensesView()
        .environment(\.expenseService, MockExpensesService(delay: 0, shouldFail: true))
}
