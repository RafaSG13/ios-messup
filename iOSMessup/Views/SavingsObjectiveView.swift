//
//  SavingsObjectiveView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import SwiftUI

struct SavingsObjectiveView: View {
    let linearGradient = LinearGradient(colors: [.cyan, .mint, .green],
                                        startPoint: .leading, endPoint: .trailing)
    @State var savingGoal: SavingGoal = SavingGoal.mockArray.randomElement() ?? SavingGoal.mock
    var deposits: [Deposit] = Deposit.mockArray

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ProgressSectionView
                        .padding(.horizontal)
                    GoalSummarySectionView
                    CircularProgressSection

                    VStack(alignment: .leading) {
                        ListSectionHeaderView(sectionTitle: "Recent Deposits", destination: AnyView(Text("Deposits")))
                        ForEach(deposits) { deposit in
                            DepositCellView(deposit: deposit)
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
        .onAppear {
            savingGoal = SavingGoal.mockArray.randomElement() ?? SavingGoal.mock
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
        VStack(spacing: 5) {
            HStack {
                HStack {
                    Text("$12K")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                        .bold()
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(.yellow.opacity(0.1))
                        )

                    Text("of \(savingGoal.amount.toAbbreviateMoneyString()) 🏁")
                }.font(.subheadline)

                Spacer()
                Text("33%")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
            }
            ProgressBar(progress: 0.9, progressColor: linearGradient)
        }
    }

    var GoalSummarySectionView: some View {
        let color = savingGoal.savingCategory.color
        return VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.5))
            HStack {
                Image(systemName: savingGoal.savingCategory.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(savingGoal.savingCategory.color)
                    .padding(.leading)
//                    .symbolEffect(.wiggle, options: .speed(0.1), isActive: true)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(savingGoal.name)
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 20)
                    Text(savingGoal.savingCategory.rawValue + " Date")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 5)
                    Text(savingGoal.completionDate.textValue)
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
        HStack(spacing: 30) {
            CircularSavingProgressView(progress: 0.45,
                                       lineWidth: 15,
                                       progressColor: .green,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: "1.6K",
                                      subtitle: "Earned",
                                      backgroundColor: .secondary,
                                      progressColor: .green)
            }
            CircularSavingProgressView(progress: 0.55,
                                       lineWidth: 15,
                                       progressColor: .yellow,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: "1.4K",
                                      subtitle: "Left",
                                      backgroundColor: .secondary,
                                      progressColor: .yellow)
            }
            CircularSavingProgressView(progress: 1,
                                       lineWidth: 15,
                                       progressColor: .blue,
                                       backgroundColor: .secondary.opacity(0.3)) {
                circularProgressLabel(progress: savingGoal.amount.toAbbreviateMoneyString(),
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
