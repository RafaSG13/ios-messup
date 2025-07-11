//
//  IncomeObjectiveView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct IncomeObjectiveView: View {
    @Environment(\.incomeRepository) private var incomeRepository
    @State private var selectedDeposit: Deposit? = nil
    @State private var lastDeposits: [Deposit] = []
    @State private var shouldPresentAddDepositModal: Bool = false
    @State private var shouldPresentEditDepositModal: Bool = false

    var body: some View {

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ProgressSectionView
                        .padding(.horizontal)
                    GoalSummarySectionView
                    CircularProgressSection
                    
                    VStack(alignment: .leading) {
                        ListSectionHeaderView(sectionTitle: "Recent Deposits", route: .depositList)
                            .padding(.horizontal)
                        MUCustomVerticalForEach(items: $lastDeposits,
                                                selection: $selectedDeposit) { deposit in
                            DepositCellView(deposit: deposit)
                        } onDelete: { deposit, _ in
                            Task { try await incomeRepository.deleteDeposit(deposit) }
                        }
                        .onChange(of: selectedDeposit) { _, newValue in
                            shouldPresentEditDepositModal = newValue != nil
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        shouldPresentAddDepositModal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .buttonStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .navigationTitle("Saving Goal")
            .navigationBarTitleDisplayMode(.inline)
            .editDepositSheet(isPresented: $shouldPresentEditDepositModal, selectedDeposit: $selectedDeposit) { deposit in
                try await incomeRepository.updateDeposit(with: deposit)
            }
            .addDepositSheet(isPresented: $shouldPresentAddDepositModal) { deposit in
                try await incomeRepository.createDeposit(deposit)
            }
        }
        .onAppear {
            lastDeposits = incomeRepository.lastDeposits(limit: 7)
        }
    }
}

// MARK: - IncomeObjectiveView + Components

extension IncomeObjectiveView {

    @ViewBuilder func circularProgressLabel(progress: String,
                                            subtitle: String,
                                            backgroundColor: Color,
                                            progressColor: Color) -> some View {
        VStack {
            Text(progress)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(progressColor)
            Text(subtitle)
                .font(.system(size: 14))
                .bold()
                .foregroundStyle(progressColor)
        }
    }

    var ProgressSectionView: some View {
        let actualProgress = incomeRepository.calculateActualProgress()
        let actualFounded = incomeRepository.calculateTotalFounded().toAbbreviateMoneyString()
        return VStack(spacing: 5) {
            HStack {
                HStack {
                    Text(actualFounded)
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                        .bold()
                        .padding(MUSpacer.size02)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.yellow.opacity(0.1))
                        )

                    Text("of \(incomeRepository.savingGoal?.amount.toAbbreviateMoneyString() ?? "0$") 🏁")
                }.font(.subheadline)

                Spacer()
                Text(actualProgress.formatToPercentageString())
                    .font(.largeTitle)
                    .foregroundStyle(.green)
            }
            ProgressBar(progress: incomeRepository.calculateActualProgress(),
                        progressColor: LinearGradient(colors: [.cyan, .mint, .green],
                                                      startPoint: .leading, endPoint: .trailing))
        }
    }

    var GoalSummarySectionView: some View {
        let color = incomeRepository.savingGoal?.savingCategory.color ?? .clear
        return VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.5))
            HStack {
                Image(systemName: incomeRepository.savingGoal?.savingCategory.icon ?? "home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(incomeRepository.savingGoal?.savingCategory.color ?? .clear)
                    .padding(.leading)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(incomeRepository.savingGoal?.name ?? "")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, MUSpacer.size05)
                    Text((incomeRepository.savingGoal?.savingCategory.rawValue ?? "") + " Date")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, MUSpacer.size02)
                    Text(incomeRepository.savingGoal?.completionDate.textValue ?? "")
                        .font(.title)
                        .bold()
                        .padding(.bottom, MUSpacer.size03)
                    Text("In 122 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(MUSpacer.size02)
                        .background(
                            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
                        )
                }
                .frame(maxHeight: .infinity)
            }
            .padding()
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [color.opacity(0.5), color.opacity(0.1), .white], startPoint: .topLeading, endPoint: .bottomTrailing))
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.5))
        }
    }

    var CircularProgressSection: some View {
        let actualProgress = incomeRepository.calculateActualProgress()
        let actualFounded = incomeRepository.calculateTotalFounded().toAbbreviateMoneyString()
        let remainingAmount = (incomeRepository.savingGoal?.amount ?? 0) - incomeRepository.calculateTotalFounded()
        return HStack(spacing: 30) {
            CircularSavingProgressView(progress: actualProgress,
                                       lineWidth: 15,
                                       progressColor: .green,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: actualFounded,
                                      subtitle: "Earned",
                                      backgroundColor: .secondary,
                                      progressColor: .green)
            }
            CircularSavingProgressView(progress: 1 - actualProgress,
                                       lineWidth: 15,
                                       progressColor: .yellow,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: remainingAmount.toAbbreviateMoneyString(),
                                      subtitle: "Left",
                                      backgroundColor: .secondary,
                                      progressColor: .yellow)
            }
            CircularSavingProgressView(progress: 1,
                                       lineWidth: 15,
                                       progressColor: .blue,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: incomeRepository.savingGoal?.amount.toAbbreviateMoneyString() ?? "",
                                      subtitle: "Required",
                                      backgroundColor: .secondary,
                                      progressColor: .blue)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, MUSpacer.size06)
    }
}

// MARK: - Preview

#Preview {
    IncomeObjectiveView()
}
