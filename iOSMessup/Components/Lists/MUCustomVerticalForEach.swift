//
//  MUCustomVerticalForEach.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

//MARK: - SwipeAction Model

fileprivate struct SwipeAction<T: Identifiable & Equatable>: Identifiable {
    var item: T
    var offset: CGFloat = 0

    var id: T.ID {
        item.id
    }
}

struct MUCustomVerticalForEach<T: Identifiable & Equatable, Content: View>: View {
    @Binding var selection: T?
    var items: [T]
    var content: (T) -> Content
    var onTap: ((T) -> Void)?
    var onDelete: ((IndexSet) -> Void)?
    @State private var swipeCandidates: [SwipeAction<T>] = []
    @State private var swipedIndex: Int? = nil

    private enum ViewTraits {
        static var viewPadding: CGFloat { 20 }
    }

    //MARK: - Initializer

    init(items: [T],
         selection: Binding<T?>,
         content: @escaping (T) -> Content,
         onTap: ((T) -> Void)? = nil,
         onDelete: ((IndexSet) -> Void)? = nil) {
        self.items = items
        self._selection = selection
        self.content = content
        self.onTap = onTap
        self.onDelete = onDelete
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(swipeCandidates) { candidate in
                if let index = swipeCandidates.firstIndex(where: { $0.id == candidate.id }) {
                    content(candidate.item)
                        .onTapGesture {
                            onTapGesture(for: index, item: candidate.item)
                        }
                        .gesture(DragGesture()
                            .onChanged { onChange(translation: $0.translation.width, for: index) }
                            .onEnded { _ in onEnd(for: index) }
                        )
                        .padding(.horizontal)
                        .background(Color(.systemBackground))
                        .offset(x: swipeCandidates[index].offset)
                        .background(DeleteActionView(for: index))
                        .overlay(SelectedViewOverlay(candidate.item))
                }
            }
        }
        .task { syncSwipeCandidates() }
    }
}

//MARK: - Custom View Components

private extension MUCustomVerticalForEach {

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

    @ViewBuilder func SelectedViewOverlay(_ item: T) -> some View {
        selection?.id == item.id
        ? Color.secondary.opacity(0.3) :  .clear
    }
}

// MARK: - Private Methods

private extension MUCustomVerticalForEach {

    func onChange(translation: CGFloat, for index: Int) {
        guard index < swipeCandidates.count else { return }

        withAnimation {
            if swipedIndex != index {
                resetAllOffsets(except: index)
                swipedIndex = index
            }

            if translation < 0 {
                swipeCandidates[index].offset = translation
            } else if translation > 0 && swipeCandidates[index].offset < 0 {
                swipeCandidates[index].offset = translation
            }
        }
    }

    func onEnd(for index: Int) {
        guard index < swipeCandidates.count else { return }

        let removeThreshold: CGFloat = UIScreen.main.bounds.width * (2/3)
        let candidate = swipeCandidates[index]

        withAnimation(.default) {
            switch candidate.offset {
            case 0:
                swipedIndex = nil
            case let offset where offset > 0:
                swipeCandidates[index].offset = 0
                swipedIndex = nil
            case let offset where offset < -removeThreshold:
                deleteItem(at: index)
            default:
                swipeCandidates[index].offset = -100
            }
        }
    }

    func onTapGesture(for index: Int, item: T) {
        withAnimation(.default) {
            if swipeCandidates[index].offset < 0 {
                resetOffset(for: index)
            } else {
                selection = item
                onTap?(item)
            }
        }
    }

    func resetOffset(for index: Int) {
        guard index < swipeCandidates.count else { return }
        withAnimation {
            swipeCandidates[index].offset = 0
            swipedIndex = nil
        }
    }

    func resetAllOffsets(except index: Int) {
        for i in swipeCandidates.indices where i != index {
            swipeCandidates[i].offset = 0
        }
    }

    func syncSwipeCandidates() {
        swipeCandidates = items.map { SwipeAction(item: $0) }
    }

    func deleteItem(at index: Int) {
        guard index < swipeCandidates.count else { return }
        let indexSet = IndexSet(integer: index)
        withAnimation {
            onDelete?(indexSet)
            swipeCandidates.remove(at: index)
            swipedIndex = nil
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
            onDelete: { indexSet in
                mockItems.remove(atOffsets: indexSet)
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
