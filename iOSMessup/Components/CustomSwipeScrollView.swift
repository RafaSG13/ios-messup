//
//  CustomSwipeScrollView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

fileprivate struct SwipeAction<T: Identifiable>: Identifiable {
    var item: T
    var offset: CGFloat = 0

    var id: T.ID {
        item.id
    }
}

struct MUCustomForEach<T: Identifiable, Content: View>: View {
    var items: [T]
    var content: (T) -> Content
    var onDelete: (Int) -> Void

    init(items: [T], content: @escaping (T) -> Content, onDelete: @escaping (Int) -> Void) {
        self.items = items
        self.content = content
        self.onDelete = onDelete
    }

    @State private var swipeCandidates: [SwipeAction<T>] = []

    var body: some View {
            ForEach(swipeCandidates) { candidate in
                let index = swipeCandidates.firstIndex(where: { $0.id == candidate.id }) ?? 0
                content(candidate.item)
                    .onTapGesture {
                        if swipeCandidates[index].offset < 0 {
                            resetOffSetOnTap(for: index)
                        }
                        else {
                            //tap action
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
                                    onDelete(index)
                                    removeItem(at: index)
                                }
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.trailing)
                            }
                        }
                    }
            }.onAppear { populateSwipeCandidates() }
    }
}

//MARK: Private Methods

private extension MUCustomForEach {

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
        let removeThreshold: CGFloat = UIScreen.main.bounds.width * (2/3)

        if swipeCandidates[index].offset > 0 {
            withAnimation {
                swipeCandidates[index].offset = 0
            }
        } else if swipeCandidates[index].offset < -removeThreshold {
            withAnimation {
                onDelete(index)
                removeItem(at: index)
            }
        } else if swipeCandidates[index].offset < -100 || swipeCandidates[index].offset < 0 {
            withAnimation { swipeCandidates[index].offset = -100 }
        }
    }

    func resetOffSetOnTap(for index: Int) {
        if swipeCandidates[index].offset < 0 {
            withAnimation { swipeCandidates[index].offset = 0 }
        }
    }

    func populateSwipeCandidates() {
        swipeCandidates = items.map { SwipeAction(item: $0) }
    }

    func removeItem(at index: Int) {
        _ = withAnimation {  swipeCandidates.remove(at: index) }
    }
}

//MARK: - Previews

#Preview {
    NavigationStack {
        ScrollView {
            MUCustomForEach(items: Expense.mockArray) { expense in
                ExpenseCellView(expense: expense)
            } onDelete: { index in
                print("Deleting item \(Expense.mockArray[index].name)")
                Expense.mockArray.remove(at: index)
            }
        }.scrollIndicators(.hidden)
    }
}
