//
//  MUCustomVerticalForEach.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

//MARK: - MUForEachItem Model

struct MUCustomVerticalForEach<T: Identifiable & Equatable, Content: View>: View {
    @State private(set) var items: [T]
    @Binding var selection: T?
    var content: (T) -> Content
    var onTap: ((T) -> Void)?
    var onDelete: ((T, IndexSet) -> Void)?

    @State private var swipedIndex: Int? = nil
    @State private var swipedOffset: CGFloat = 0

    private enum ViewTraits {
        static var viewPadding: CGFloat { 20 }
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(items, id: \.id) { item in
                if let index = items.firstIndex(where: { $0.id == item.id }) {
                    content(item)
                        .onTapGesture {
                            onTapGesture(for: index, item: item)
                        }
                        .gesture(DragGesture()
                            .onChanged { onChange(translation: $0.translation, for: index) }
                            .onEnded { _ in onEnd(for: index) }
                        )
                        .padding(.horizontal)
                        .background(Color(.systemBackground))
                        .offset(x: swipedIndex == index ? swipedOffset : 0)
                        .background(DeleteActionView(for: index))
                        .overlay(SelectedViewOverlay(item))
                        .animation(.bouncy, value: swipedOffset)
                        .animation(.bouncy, value: swipedIndex)
                }
            }
        }
    }
}

//MARK: - Custom View Components

private extension MUCustomVerticalForEach {
    
    @ViewBuilder func DeleteActionView(for index: Int) -> some View {
        if swipedIndex == index {
            ZStack {
                Color.red
                    .padding(.leading, ViewTraits.viewPadding + swipedOffset)
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
        } else {
            Color.clear
        }
    }

    @ViewBuilder func SelectedViewOverlay(_ item: T) -> some View {
        selection?.id == item.id
        ? Color.secondary.opacity(0.3) :  .clear
    }
}

// MARK: - Private Methods

private extension MUCustomVerticalForEach {
    
    func onChange(translation: CGSize, for index: Int) {
        guard index < items.count,
              abs(translation.width) > abs(translation.height) else { return }

        if swipedIndex != index {
            swipedIndex = index
        }

        if translation.width < 0 {
            swipedOffset = translation.width
        } else if translation.width > 0 && swipedOffset < 0 {
            swipedOffset = translation.width
        }
    }

    func onEnd(for index: Int) {
        guard index < items.count else { return }
        let removeThreshold: CGFloat = UIScreen.main.bounds.width * (2/3)

        switch swipedOffset {
        case 0:
            swipedIndex = nil
        case let offset where offset > 0:
            resetOffset()
        case let offset where offset < -removeThreshold:
            deleteItem(at: index)
        default:
            swipedOffset = -100
        }
    }

    func onTapGesture(for index: Int, item: T) {
        if swipedOffset < 0 {
            resetOffset()
        } else {
            selection = item
            onTap?(item)
        }
    }

    func resetOffset() {
        swipedOffset = 0
        swipedIndex = nil
    }

    func deleteItem(at index: Int) {
        guard index < items.count else { return }
        let indexSet = IndexSet(integer: index)
        withAnimation(.spring) {
            onDelete?(items[index], indexSet)
            items.remove(at: index)
            resetOffset()
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var mockItems = Expense.mockArray
    @Previewable @State var selection: Expense?
    @Previewable @State var shouldEdit: Bool = false

    NavigationStack {
        ScrollView {
            MUCustomVerticalForEach(items: mockItems, selection: $selection) { expense in
                ExpenseCellView(expense: expense)
            } onTap: { value in
                print("Tapped item \(selection?.name ?? "")")
            }
            onDelete: { item, indexSet in
                mockItems.removeAll { $0.id == item.id }
            }
            .onChange(of: selection) { _, newValue in
                shouldEdit = newValue != nil
            }
            .editExpenseSheet(isPresented: $shouldEdit, selectedItem: $selection, onSubmit: { expense in
                print("Editing item: \(expense.name)")
            })
            .scrollIndicators(.hidden)
        }
    }
}
