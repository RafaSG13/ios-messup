//
//  CustomSwipeScrollView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

fileprivate struct SwipeAction: Identifiable {
    var expense: Expense
    var offset: CGFloat = 0

    var id: String {
        expense.id
    }
}

struct CustomSwipeScrollView: View {
    @Environment(\.expenseVM) private var expenseVM
    @State private var swipeCandidates: [SwipeAction] = []

    var body: some View {
        ScrollView {
            ForEach(swipeCandidates) { candidate in
                let index = swipeCandidates.firstIndex(where: { $0.id == candidate.id }) ?? 0
                ExpenseCellView(expense: candidate.expense)
                    .onTapGesture {
                        if swipeCandidates[index].offset < 0 {
                            withAnimation {
                                swipeCandidates[index].offset = 0
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background()
                    .gesture(DragGesture()
                        .onChanged {
                            onChange(translation: $0.translation.width, for: index)
                        }.onEnded { _ in
                            onEnd(for: index)
                        })
                    .offset(x: swipeCandidates[index].offset, y: 0)
                    .background {
                        ZStack {
                            Color.red
                            HStack {
                                Spacer()
                                Button("Delete") {
                                    onDelete(for: index)
                                }
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.trailing)
                            }
                        }
                    }
            }
        }
        .padding(.top)
        .scrollIndicators(.hidden)
        .onAppear { populateSwipeCandidates() }
    }
    
    func onChange(translation: CGFloat, for index: Int) {
        if translation < 0 {
            withAnimation {
                swipeCandidates[index].offset = translation
            }
        } else if translation > 0 && swipeCandidates[index].offset < 0 {
            withAnimation {
                swipeCandidates[index].offset = translation
            }
        }
            
    }

    func onEnd(for index: Int) {
        if swipeCandidates[index].offset > 0 {
            withAnimation {
                swipeCandidates[index].offset = 0
            }
        } else if swipeCandidates[index].offset < -200 {
            withAnimation {
                onDelete(for: index)
            }
        } else if swipeCandidates[index].offset < -100 || swipeCandidates[index].offset < 0 {
            withAnimation {
                swipeCandidates[index].offset = -100
            }
        }
    }

    func populateSwipeCandidates() {
        expenseVM.expenses.forEach { swipeCandidates.append(SwipeAction(expense: $0)) }
    }

    func onDelete(for index: Int) {
        Task {
            try await expenseVM.delete(removeAt: IndexSet(integer: index))
        }
        _ = withAnimation {
            swipeCandidates.remove(at: index)
        }
    }
}

#Preview {
    NavigationStack {
        CustomSwipeScrollView()
    }
}
