//
//  SavingsObjectiveView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct SavingsObjectiveView: View {
    @Environment(\.savingVM) private var savingViewModel
    @State private var selectedDeposit: Deposit?
    
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
                        ForEach(savingViewModel.deposits) { deposit in
                            DepositCellView(deposit: deposit)
                                .selectableCell {
                                    selectedDeposit = deposit
                                }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        print("Add Deposit tapped")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Edit Goal tapped")
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            .buttonStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.always)
            .navigationTitle("Saving Goal")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - SavingsObjectiveView + Components

extension SavingsObjectiveView {

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
        let actualProgress = savingViewModel.calculateActualProgress()
        let actualFounded = savingViewModel.calculateTotalFounded().toAbbreviateMoneyString()
        return VStack(spacing: 5) {
            HStack {
                HStack {
                    Text(actualFounded)
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                        .bold()
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.yellow.opacity(0.1))
                        )

                    Text("of \(savingViewModel.savingGoal?.amount.toAbbreviateMoneyString() ?? "0$") 🏁")
                }.font(.subheadline)

                Spacer()
                Text(actualProgress.formatToPercentageString())
                    .font(.largeTitle)
                    .foregroundStyle(.green)
            }
            ProgressBar(progress: savingViewModel.calculateActualProgress(),
                        progressColor: LinearGradient(colors: [.cyan, .mint, .green],
                                                      startPoint: .leading, endPoint: .trailing))
        }
    }

    var GoalSummarySectionView: some View {
        let color = savingViewModel.savingGoal?.savingCategory.color ?? .clear
        return VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.5))
            HStack {
                Image(systemName: savingViewModel.savingGoal?.savingCategory.icon ?? "home")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(savingViewModel.savingGoal?.savingCategory.color ?? .clear)
                    .padding(.leading)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(savingViewModel.savingGoal?.name ?? "")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 20)
                    Text((savingViewModel.savingGoal?.savingCategory.rawValue ?? "") + " Date")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 5)
                    Text(savingViewModel.savingGoal?.completionDate.textValue ?? "")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 10)
                    Text("In 122 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(3)
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
        let actualProgress = savingViewModel.calculateActualProgress()
        let actualFounded = savingViewModel.calculateTotalFounded().toAbbreviateMoneyString()
        let remainingAmount = (savingViewModel.savingGoal?.amount ?? 0) - savingViewModel.calculateTotalFounded()
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
                circularProgressLabel(progress: savingViewModel.savingGoal?.amount.toAbbreviateMoneyString() ?? "",
                                      subtitle: "Required",
                                      backgroundColor: .secondary,
                                      progressColor: .blue)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 25)
    }
}

// MARK: - Preview

#Preview {
    SavingsObjectiveView()
}
