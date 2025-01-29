//
//  CustomSwipeScrollView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

fileprivate struct SwipeAction<T: Identifiable & Equatable>: Identifiable {
    var item: T
    var offset: CGFloat = 0

    var id: T.ID {
        item.id
    }
}

struct MUCustomForEach<T: Identifiable & Equatable, Content: View>: View {
    @Binding var items: [T]
    @Binding var selectedItem: T?
    var content: (T) -> Content
    var onTap: (T) -> Void
    var onDelete: (Int) -> Void
    @State private var swipeCandidates: [SwipeAction<T>] = []

    private enum ViewTraits {
        static var viewPadding: CGFloat { 20 }
    }

    //MARK: - Custom View Properties

    var rowTint: Color? = nil

    var body: some View {
        ForEach(swipeCandidates) { candidate in
            if let index = swipeCandidates.firstIndex(where: { $0.id == candidate.id }) {
                content(candidate.item)
                    .onTapGesture {
                        selectedItem = candidate.item
                        if swipeCandidates[index].offset < 0 {
                            resetOffset(for: index)
                        } else {
                            onTap(candidate.item)
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged { onChange(translation: $0.translation.width, for: index) }
                        .onEnded { _ in onEnd(for: index) }
                    )
                    .padding(.horizontal)
                    .background(rowTint ?? Color(.systemBackground))
                    .overlay(isSelected(candidate.item) ? Color.secondary.opacity(0.3) : .clear)
                    .offset(x: swipeCandidates[index].offset)
                    .background {
                        DeleteActionView(for: index)
                    }
            }
        }
        .onAppear { syncSwipeCandidates() }
        .onChange(of: items) {
            syncSwipeCandidates()
        }
    }
}

//MARK: - Custom View Components

private extension MUCustomForEach {
    
    @ViewBuilder func DeleteActionView(for index: Int) -> some View {
        ZStack {
            Color.red
                .padding(.leading, ViewTraits.viewPadding + swipeCandidates[index].offset)
            HStack {
                Spacer()
                Button("Delete") {
                    deleteItem(at: index)
                }
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.trailing, ViewTraits.viewPadding)
            }
        }
    }
}

// MARK: - Private Methods

private extension MUCustomForEach {
    
    func onChange(translation: CGFloat, for index: Int) {
        guard index < swipeCandidates.count else { return }

        withAnimation {
            if translation < 0 {
                swipeCandidates[index].offset = translation
            } else if translation > 0 && swipeCandidates[index].offset <= 0 {
                swipeCandidates[index].offset = translation
            }
        }
    }

    func onEnd(for index: Int) {
        guard index < swipeCandidates.count else { return }
        
        let removeThreshold: CGFloat = UIScreen.main.bounds.width * (2/3)
        let candidate = swipeCandidates[index]

        withAnimation(.default.speed(1)) {
            if candidate.offset == 0 {
                return
            } else if candidate.offset > 0 {
                swipeCandidates[index].offset = 0
            } else if candidate.offset < -removeThreshold {
                deleteItem(at: index)
            } else {
                swipeCandidates[index].offset = -100
            }
        }
    }

    func resetOffset(for index: Int) {
        guard index < swipeCandidates.count else { return }
        withAnimation { swipeCandidates[index].offset = 0 }
    }

    func syncSwipeCandidates() {
        swipeCandidates = items.map { SwipeAction(item: $0) }
    }

    func deleteItem(at index: Int) {
        guard index < swipeCandidates.count else { return }
        withAnimation {
            onDelete(index)
            swipeCandidates.remove(at: index)
        }
    }

    func isSelected(_ item: T) -> Bool {
        selectedItem?.id == item.id
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var mockItems = Expense.mockArray
    @Previewable @State var selectedItem: Expense?

    NavigationStack {
        ScrollView {
            MUCustomForEach(items: $mockItems, selectedItem: $selectedItem) { expense in
                ExpenseCellView(expense: expense)
            } onTap: { _ in
                print("Tapped item")
            }
            onDelete: { index in
                print("Deleting item \(mockItems[index].name)")
                mockItems.remove(at: index)
            }
        }
        .scrollIndicators(.hidden)
    }
}

