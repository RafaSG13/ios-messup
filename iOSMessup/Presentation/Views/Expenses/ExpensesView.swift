//
//  ExpensesView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpensesView

/// Owns the screen state (period, sheets, selection). Every data read lives in `ExpensesDashboard`,
/// so presenting a sheet does not recompute the summary.
struct ExpensesView: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.intelligenceService) private var intelligenceService
    @State private var kind = PeriodKind.month
    @State private var anchor = Date.now
    @State private var shouldPresentAddExpense = false
    @State private var isPresentingBudget = false
    @State private var isPresentingAssistant = false
    @State private var selectedItem: Expense?
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack {
            ExpensesDashboard(kind: $kind,
                              anchor: $anchor,
                              isPresentingAddExpense: $shouldPresentAddExpense,
                              isPresentingBudget: $isPresentingBudget,
                              selectedItem: $selectedItem,
                              error: $error)
                .navigationTitle("Expenses")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Route.self) { RouteDestinationView(route: $0) }
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

// MARK: - ExpensesDashboard

private struct ExpensesDashboard: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.incomeService) private var incomeService
    @Environment(\.savingsService) private var savingsService
    @Environment(\.budgetService) private var budgetService
    @Binding var kind: PeriodKind
    @Binding var anchor: Date
    @Binding var isPresentingAddExpense: Bool
    @Binding var isPresentingBudget: Bool
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?

    var body: some View {
        let period = Period(kind: kind, containing: anchor)
        let summary = PeriodSummary(period: period,
                                    expenses: expenseService.expenses,
                                    incomes: incomeService.incomes,
                                    contributions: savingsService.contributions)
        // The budget only applies to months.
        let monthlyLimit = kind == .month ? budgetService.budget?.monthlyLimit : nil
        let categoryLimits: [Category: BudgetProgress] = kind == .month
            ? Dictionary(uniqueKeysWithValues: summary.categoryTotals.compactMap { item in
                budgetService.progress(for: item.category, spent: item.amount).map { (item.category, $0) }
            })
            : [:]

        List {
            if expenseService.expenses.isEmpty {
                MUEmptyState("No transactions",
                             systemImage: "creditcard",
                             description: "Add your first expense to see your spending here.",
                             actionTitle: "Add expense") {
                    isPresentingAddExpense = true
                }
                .clearListRow()
            } else {
                Section {
                    PeriodPicker(kind: $kind, anchor: $anchor)
                }

                Section {
                    ExpensesCarousel(summary: summary,
                                     monthlyLimit: monthlyLimit,
                                     showsBudget: kind == .month,
                                     budgetProgress: kind == .month ? budgetService.progress(spent: summary.spent) : nil,
                                     isPresentingBudget: $isPresentingBudget)
                        .clearListRow(insets: EdgeInsets())
                }
                ExpensesCategoriesSection(summary: summary, categoryLimits: categoryLimits)
                RecentExpensesSection(kind: kind, anchor: anchor, selectedItem: $selectedItem, error: $error)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(MUSpacer.size04)
    }
}

// MARK: - ExpensesCarousel

private enum CarouselPageKind {
    case spent
    case spending
    case insights
}

/// Spent, Spending and Insights as one horizontally paged, endlessly looping card with page dots.
/// The pages are repeated and the scroll position is moved back to the middle band when it gets near an end.
private struct ExpensesCarousel: View {
    let summary: PeriodSummary
    let monthlyLimit: Double?
    let showsBudget: Bool
    let budgetProgress: BudgetProgress?
    @Binding var isPresentingBudget: Bool
    @State private var position: Int?

    private enum ViewTraits {
        static let repeats = 21
        static let recenterDistance = 5
    }

    var body: some View {
        let insights = Insight.make(from: summary, monthlyLimit: monthlyLimit)
        let kinds: [CarouselPageKind] = insights.isEmpty ? [.spent, .spending] : [.spent, .spending, .insights]
        let count = kinds.count
        let start = (ViewTraits.repeats / 2) * count

        VStack(spacing: MUSpacer.size03) {
            // Invisible copy of every page: gives the carousel the height of the tallest one.
            ZStack(alignment: .top) {
                ForEach(kinds.indices, id: \.self) { index in
                    CarouselPage(kind: kinds[index],
                                 summary: summary,
                                 monthlyLimit: monthlyLimit,
                                 showsBudget: showsBudget,
                                 budgetProgress: budgetProgress,
                                 insights: insights,
                                 isPresentingBudget: $isPresentingBudget)
                }
            }
            .hidden()
            .accessibilityHidden(true)
            .overlay {
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(0..<(count * ViewTraits.repeats), id: \.self) { index in
                            CarouselPage(kind: kinds[index % count],
                                         summary: summary,
                                         monthlyLimit: monthlyLimit,
                                         showsBudget: showsBudget,
                                         budgetProgress: budgetProgress,
                                         insights: insights,
                                         isPresentingBudget: $isPresentingBudget)
                                .containerRelativeFrame(.horizontal)
                                .modifier(CarouselPageTransition())
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $position)
                .onAppear { position = start }
                .onChange(of: count) { position = start }
                .onChange(of: position) { _, new in
                    let limit = count * ViewTraits.recenterDistance
                    guard let new, new < start - limit || new >= start + limit else { return }
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { position = start + new % count }
                }
            }

            CarouselDots(count: count, selected: (position ?? 0) % count)
        }
    }
}

// MARK: - CarouselPage

private struct CarouselPage: View {
    let kind: CarouselPageKind
    let summary: PeriodSummary
    let monthlyLimit: Double?
    let showsBudget: Bool
    let budgetProgress: BudgetProgress?
    let insights: [Insight]
    @Binding var isPresentingBudget: Bool

    var body: some View {
        // identity change intended: each page is a different card with its own state
        switch kind {
        case .spent:
            ExpensesSummaryCard(summary: summary,
                                showsBudget: showsBudget,
                                budgetProgress: budgetProgress,
                                isPresentingBudget: $isPresentingBudget)
        case .insights:
            ExpenseInsightsCard(insights: insights, summary: summary, monthlyLimit: monthlyLimit)
        case .spending:
            MUCard("Spending") {
                CumulativeSpendingChart(summary: summary, monthlyLimit: monthlyLimit)
            }
        }
    }
}

// MARK: - CarouselPageTransition

/// Fades and shrinks a page as it leaves the center, so a partial drag blends the two cards.
private struct CarouselPageTransition: ViewModifier {
    private enum ViewTraits {
        static let minimumOpacity = 0.35
        static let minimumScale = 0.92
    }

    func body(content: Content) -> some View {
        content.scrollTransition(axis: .horizontal) { view, phase in
            let distance = abs(phase.value)
            return view
                .opacity(1 - distance * (1 - ViewTraits.minimumOpacity))
                .scaleEffect(1 - distance * (1 - ViewTraits.minimumScale))
        }
    }
}

// MARK: - CarouselDots

private struct CarouselDots: View {
    let count: Int
    let selected: Int

    private enum ViewTraits {
        static let dotSize: CGFloat = 8
        static let inactiveOpacity = 0.3
    }

    var body: some View {
        HStack(spacing: MUSpacer.size02) {
            ForEach(0..<count, id: \.self) { page in
                Circle()
                    .fill(page == selected ? Color.primary : Color.secondary.opacity(ViewTraits.inactiveOpacity))
                    .frame(width: ViewTraits.dotSize, height: ViewTraits.dotSize)
            }
        }
        .animation(.snappy, value: selected)
        .accessibilityHidden(true)
    }
}

// MARK: - ExpensesCategoriesSection

private struct ExpensesCategoriesSection: View {
    let summary: PeriodSummary
    let categoryLimits: [Category: BudgetProgress]

    var body: some View {
        Section {
            MUCard("Categories") {
                if summary.categoryTotals.isEmpty {
                    Text("No expenses in this period.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    CategoryBreakdownView(totals: summary.categoryTotals, limit: 5, limitProgress: categoryLimits)
                }
            }
            .clearListRow(insets: EdgeInsets())
        }
    }
}

// MARK: - RecentExpensesSection

/// The newest expenses of the period, most recent first.
private struct RecentExpensesSection: View {
    @Environment(\.expenseService) private var expenseService
    let kind: PeriodKind
    let anchor: Date
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?

    var body: some View {
        let period = Period(kind: kind, containing: anchor)
        let recent = Array(expenseService.expenses.filter { period.contains($0.date) }.sorted().suffix(6).reversed())

        Section {
            if recent.isEmpty {
                Text("No expenses in this period")
                    .foregroundStyle(.secondary)
            }
            ForEach(recent) { expense in
                ExpenseListRow(expense: expense, selectedItem: $selectedItem, error: $error)
            }
        } header: {
            ListSectionHeaderView(sectionTitle: "Transactions",
                                  actionTitle: "View all",
                                  value: Route.transactionList)
            .textCase(nil)
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
