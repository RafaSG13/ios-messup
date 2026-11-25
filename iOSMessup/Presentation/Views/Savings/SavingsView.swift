//
//  SavingsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

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
                goalSection
                contributionsSection
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

// MARK: - Sections

private extension SavingsView {
    var goalSection: some View {
        Section {
            if let goal = savingsService.savingGoal, let progress = savingsService.progress() {
                SavingGoalCardView(goal: goal, progress: progress)
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
    var contributionsSection: some View {
        if savingsService.savingGoal != nil {
            let contributions = savingsService.contributions.sorted().reversed()
            if contributions.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No contributions", systemImage: "banknote")
                    } description: {
                        Text("Contributions you add count toward your saving goal.")
                    } actions: {
                        Button("Add contribution") { isAddingContribution = true }
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } header: {
                    Text("Contributions")
                        .textCase(nil)
                }
            } else {
                Section {
                    ForEach(contributions) { contribution in
                        ContributionCellView(contribution: contribution)
                            .selectableCell { selectedContribution = contribution }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) { delete(contribution) }
                            }
                    }
                } header: {
                    Text("Contributions")
                        .textCase(nil)
                }
            }
        }
    }
}

// MARK: - Actions

private extension SavingsView {
    func delete(_ contribution: Contribution) {
        Task {
            do {
                try await savingsService.deleteContribution(contribution)
            } catch {
                self.error = error
            }
        }
    }

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
                .font(MUTypography.heroAmount)
                .foregroundStyle(.tint)
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
                .font(MUTypography.rowAmount)
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
