//
//  IncomeObjectiveView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI
import MUDesignSystem

struct IncomeObjectiveView: View {
    @Environment(\.incomeService) private var incomeService
    @State private var selectedDeposit: Deposit?
    @State private var isAddingDeposit = false
    @State private var goalFormMode: SavingGoalFormView.Mode?
    @State private var isConfirmingGoalDeletion = false
    @State private var error: (any Error)?

    var body: some View {
        let recentDeposits = Array(incomeService.lastDeposits(limit: 7).reversed())

        NavigationStack {
            List {
                goalSection
                depositsSection(recentDeposits)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Saving Goal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { $0.destination }
            .toolbar {
                if let goal = incomeService.savingGoal {
                    ToolbarItem(placement: .primaryAction) {
                        Menu("Goal options", systemImage: "ellipsis") {
                            Button("Edit goal", systemImage: "pencil") {
                                goalFormMode = .edit(goal)
                            }
                            Button("Delete goal", systemImage: "trash", role: .destructive) {
                                isConfirmingGoalDeletion = true
                            }
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add deposit", systemImage: "plus") {
                        isAddingDeposit = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .confirmationDialog("Delete saving goal?", isPresented: $isConfirmingGoalDeletion, titleVisibility: .visible) {
                Button("Delete goal", role: .destructive, action: deleteGoal)
            } message: {
                Text("Your deposits are kept.")
            }
            .errorAlert($error)
            .editDepositSheet(deposit: $selectedDeposit) { deposit in
                try await incomeService.updateDeposit(with: deposit)
            }
            .addDepositSheet(isPresented: $isAddingDeposit) { deposit in
                try await incomeService.createDeposit(deposit)
            }
            .savingGoalSheet(mode: $goalFormMode, onSubmit: submit)
        }
    }
}

// MARK: - Sections

private extension IncomeObjectiveView {
    var goalSection: some View {
        Section {
            if let goal = incomeService.savingGoal {
                SavingGoalCardView(goal: goal,
                                   progress: SavingGoalProgress(earned: incomeService.calculateTotalFounded(),
                                                                target: goal.amount))
            } else {
                ContentUnavailableView {
                    Label("No saving goal", systemImage: "flag.checkered")
                } description: {
                    Text("Set a target amount to track your progress.")
                } actions: {
                    Button("Create goal") { goalFormMode = .create }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: MUSpacer.size03, leading: MUSpacer.size04, bottom: MUSpacer.size03, trailing: MUSpacer.size04))
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    func depositsSection(_ deposits: [Deposit]) -> some View {
        if deposits.isEmpty {
            Section {
                ContentUnavailableView {
                    Label("No deposits", systemImage: "banknote")
                } description: {
                    Text("Deposits you add count toward your saving goal.")
                } actions: {
                    Button("Add deposit") { isAddingDeposit = true }
                        .buttonStyle(.borderedProminent)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } header: {
                Text("Recent Deposits")
                    .textCase(nil)
            }
        } else {
            Section {
                ForEach(deposits) { deposit in
                    DepositCellView(deposit: deposit)
                        .selectableCell { selectedDeposit = deposit }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) { delete(deposit) }
                        }
                }
            } header: {
                ListSectionHeaderView(sectionTitle: "Recent Deposits",
                                      actionTitle: "View all",
                                      value: Route.depositList)
                    .textCase(nil)
            }
        }
    }
}

// MARK: - Actions

private extension IncomeObjectiveView {
    func delete(_ deposit: Deposit) {
        Task {
            do {
                try await incomeService.deleteDeposit(deposit)
            } catch {
                self.error = error
            }
        }
    }

    func deleteGoal() {
        Task {
            do {
                try await incomeService.deleteSavingGoal()
            } catch {
                self.error = error
            }
        }
    }

    /// The form keeps the goal `id` when editing, so a matching id means update, anything else is a new goal.
    func submit(_ goal: SavingGoal) async throws {
        if incomeService.savingGoal?.id == goal.id {
            try await incomeService.updateSavingGoal(with: goal)
        } else {
            try await incomeService.createSavingGoal(goal)
        }
    }
}

// MARK: - SavingGoalCardView

private struct SavingGoalCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var iconSize: CGFloat = 48
    let goal: SavingGoal
    let progress: SavingGoalProgress

    var body: some View {
        MUCard {
            header
            if let date = goal.completionDate.date {
                targetDate(date)
            }
            progressArea
            stats
        }
    }

    private var header: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size04))

        return layout {
            Image(systemName: goal.savingCategory.icon)
                .font(.title2)
                .foregroundStyle(goal.savingCategory.color)
                .frame(width: iconSize, height: iconSize)
                .background(goal.savingCategory.color.opacity(0.15), in: .rect(cornerRadius: MURadius.medium))
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(goal.name)
                    .font(.title3.bold())
                Text(goal.savingCategory.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func targetDate(_ date: Date) -> some View {
        VStack(alignment: .leading) {
            Text("Target date")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(date, format: .dateTime.day().month(.wide).year())
                .font(.headline)
            Text(date, format: .relative(presentation: .named))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var progressArea: some View {
        VStack(alignment: .leading, spacing: MUSpacer.size03) {
            Text(progress.fraction, format: .percent.precision(.fractionLength(0)))
                .font(.largeTitle.bold())
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            ProgressBar(progress: progress.fraction)
        }
    }

    private var stats: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: MUSpacer.size03))
            : AnyLayout(HStackLayout(spacing: MUSpacer.size03))

        return layout {
            StatTileView(title: "Earned", amount: progress.earned)
            StatTileView(title: "Left", amount: progress.remaining)
            StatTileView(title: "Required", amount: progress.target)
        }
    }
}

// MARK: - StatTileView

private struct StatTileView: View {
    @Environment(\.currencyCode) private var currencyCode
    let title: LocalizedStringKey
    let amount: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text(amount.formattedCompactMoney(code: currencyCode))
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(MUSpacer.size03)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: MURadius.small))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Mock data") {
    IncomeObjectiveView()
}

#Preview("Empty") {
    IncomeObjectiveView()
        .environment(\.incomeService, MockIncomeService(initialDeposits: [], initialGoal: nil, delay: 0))
}

#Preview("No goal") {
    IncomeObjectiveView()
        .environment(\.incomeService, MockIncomeService(initialGoal: nil, delay: 0))
}

#Preview("Failing service") {
    IncomeObjectiveView()
        .environment(\.incomeService, MockIncomeService(delay: 0, shouldFail: true))
}
