//
//  SavingsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - SavingsView

struct SavingsView: View {
    @Environment(\.savingsService) private var savingsService
    @State private var selectedContribution: Contribution?
    @State private var isAddingContribution = false
    @State private var goalFormMode: SavingGoalFormView.Mode?
    @State private var isConfirmingGoalDeletion = false
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack {
            List {
                SavingGoalSection(goalFormMode: $goalFormMode)
                ContributionsSection(selectedContribution: $selectedContribution,
                                     isAddingContribution: $isAddingContribution,
                                     error: $error)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(MUSpacer.size04)
            .navigationTitle("Savings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let goal = savingsService.savingGoal {
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
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add contribution", systemImage: "plus") {
                            isAddingContribution = true
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .confirmationDialog("Delete saving goal?", isPresented: $isConfirmingGoalDeletion, titleVisibility: .visible) {
                Button("Delete goal", role: .destructive, action: deleteGoal)
            } message: {
                Text("Your contributions are kept.")
            }
            .errorAlert($error)
            .editContributionSheet(contribution: $selectedContribution) { contribution in
                try await savingsService.updateContribution(with: contribution)
            }
            .addContributionSheet(isPresented: $isAddingContribution) { contribution in
                try await savingsService.addContribution(contribution)
            }
            .savingGoalSheet(mode: $goalFormMode, onSubmit: submit)
        }
    }
}

// MARK: - Actions

private extension SavingsView {
    func deleteGoal() {
        Task {
            do {
                try await savingsService.deleteSavingGoal()
            } catch {
                self.error = error
            }
        }
    }

    /// The form keeps the goal `id` when editing, so a matching id means update, anything else is a new goal.
    func submit(_ goal: SavingGoal) async throws {
        if savingsService.savingGoal?.id == goal.id {
            try await savingsService.updateSavingGoal(with: goal)
        } else {
            try await savingsService.createSavingGoal(goal)
        }
    }
}

// MARK: - SavingGoalSection

private struct SavingGoalSection: View {
    @Environment(\.savingsService) private var savingsService
    @Binding var goalFormMode: SavingGoalFormView.Mode?

    var body: some View {
        Section {
            if let goal = savingsService.savingGoal, let progress = savingsService.progress() {
                SavingGoalCardView(goal: goal, progress: progress)
            } else {
                MUEmptyState("No saving goal",
                             systemImage: "flag.checkered",
                             description: "Set a target amount to track your progress.",
                             actionTitle: "Create goal") {
                    goalFormMode = .create
                }
            }
        }
        .clearListRow(insets: EdgeInsets(top: MUSpacer.size03,
                                         leading: MUSpacer.size04,
                                         bottom: MUSpacer.size03,
                                         trailing: MUSpacer.size04))
    }
}

// MARK: - ContributionsSection

private struct ContributionsSection: View {
    @Environment(\.savingsService) private var savingsService
    @Binding var selectedContribution: Contribution?
    @Binding var isAddingContribution: Bool
    @Binding var error: (any Error)?

    var body: some View {
        if savingsService.savingGoal != nil {
            let contributions = savingsService.contributions.sorted().reversed()
            if contributions.isEmpty {
                Section {
                    MUEmptyState("No contributions",
                                 systemImage: "banknote",
                                 description: "Contributions you add count toward your saving goal.",
                                 actionTitle: "Add contribution") {
                        isAddingContribution = true
                    }
                    .clearListRow()
                } header: {
                    Text("Contributions")
                        .textCase(nil)
                }
            } else {
                Section {
                    ForEach(contributions) { contribution in
                        ContributionListRow(contribution: contribution,
                                            selectedContribution: $selectedContribution,
                                            error: $error)
                    }
                } header: {
                    Text("Contributions")
                        .textCase(nil)
                }
            }
        }
    }
}

// MARK: - ContributionListRow

private struct ContributionListRow: View {
    @Environment(\.savingsService) private var savingsService
    let contribution: Contribution
    @Binding var selectedContribution: Contribution?
    @Binding var error: (any Error)?

    var body: some View {
        ContributionCellView(contribution: contribution)
            .selectableCell { selectedContribution = contribution }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive, action: delete)
            }
    }

    private func delete() {
        Task {
            do {
                try await savingsService.deleteContribution(contribution)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - SavingGoalCardView

private struct SavingGoalCardView: View {
    @Environment(\.currencyCode) private var currencyCode
    let goal: SavingGoal
    let progress: SavingGoalProgress

    var body: some View {
        MUCard {
            SavingGoalHeaderView(goal: goal)
            if let date = goal.completionDate.date {
                SavingGoalTargetDateView(date: date)
            }
            VStack(alignment: .leading, spacing: MUSpacer.size03) {
                MUHeroAmount(progress.fraction.formatted(.percent.precision(.fractionLength(0))),
                             value: progress.fraction,
                             tint: .accentColor)
                    .accessibilityHidden(true)
                ProgressBar(progress: progress.fraction)
            }
            MUAdaptiveStack {
                MUStatTile("Earned", value: progress.earned.formattedCompactMoney(code: currencyCode))
                MUStatTile("Left", value: progress.remaining.formattedCompactMoney(code: currencyCode))
                MUStatTile("Required", value: progress.target.formattedCompactMoney(code: currencyCode))
            }
        }
    }
}

// MARK: - SavingGoalHeaderView

private struct SavingGoalHeaderView: View {
    @ScaledMetric private var iconSize: CGFloat = 48
    let goal: SavingGoal

    var body: some View {
        MUAdaptiveStack(spacing: MUSpacer.size04) {
            MUIconTile(systemImage: goal.savingCategory.icon, tint: goal.savingCategory.color, size: iconSize)
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
}

// MARK: - SavingGoalTargetDateView

private struct SavingGoalTargetDateView: View {
    let date: Date

    var body: some View {
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
}

// MARK: - Preview

#Preview("Mock data") {
    SavingsView()
}

#Preview("Empty") {
    SavingsView()
        .environment(\.savingsService, MockSavingsService(initialGoal: nil, initialContributions: [], delay: 0))
}

#Preview("No contributions") {
    SavingsView()
        .environment(\.savingsService, MockSavingsService(initialContributions: [], delay: 0))
}

#Preview("Failing service") {
    SavingsView()
        .environment(\.savingsService, MockSavingsService(delay: 0, shouldFail: true))
}
