//
//  MUCustomVerticalForEach.swift
//  MUDesignSystem
//
//  Created by Rafael Serrano Gamarra on 28/1/25.
//

import SwiftUI

public struct MUCustomVerticalForEach<T: Identifiable & Equatable, Content: View>: View {
    @Binding var items: [T]
    @Binding var selection: T?
    var content: (T) -> Content
    var onTap: ((T) -> Void)?
    var onDelete: ((T, IndexSet) -> Void)?
    var deleteTitle: LocalizedStringKey

    @State private var swipedIndex: Int?
    @State private var swipedOffset: CGFloat = 0
    @State private var addOpacity: Bool = false
    @State private var rowWidth: CGFloat = 0

    private enum ViewTraits {
        static var viewPadding: CGFloat { 20 }
        static var minimunSwipeDistance: CGFloat { 25 }
    }

    public init(items: Binding<[T]>,
                selection: Binding<T?>,
                deleteTitle: LocalizedStringKey,
                @ViewBuilder content: @escaping (T) -> Content,
                onTap: ((T) -> Void)? = nil,
                onDelete: ((T, IndexSet) -> Void)? = nil) {
        self._items = items
        self._selection = selection
        self.deleteTitle = deleteTitle
        self.content = content
        self.onTap = onTap
        self.onDelete = onDelete
    }

    public var body: some View {
        ForEach(items, id: \.id) { item in
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                content(item)
                    .onTapGesture {
                        performOnTapEffect()
                        onTapGesture(for: index, item: item)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: ViewTraits.minimunSwipeDistance,
                                    coordinateSpace: .local)
                        .onChanged { onChange(translation: $0.translation, for: index) }
                        .onEnded { _ in onEnd(for: index, width: rowWidth) }
                    )
                    .padding(.horizontal)
                    .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { rowWidth = $0 }
                    .background(Color(.systemBackground))
                    .offset(x: swipedIndex == index ? swipedOffset : 0)
                    .background(DeleteActionView(for: index))
                    .opacity((addOpacity && selection == item) ? 0.3 : 1)
                    .animation(.bouncy, value: swipedOffset)
                    .animation(.bouncy, value: swipedIndex)
                    .animation(.easeInOut, value: addOpacity)
            }
        }
    }
}

// MARK: - Custom View Components

private extension MUCustomVerticalForEach {

    @ViewBuilder func DeleteActionView(for index: Int) -> some View {
        if swipedIndex == index {
            ZStack {
                Color.red
                    .padding(.leading, ViewTraits.viewPadding + swipedOffset)
                HStack {
                    Spacer()
                    Button(deleteTitle) {
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

    func onEnd(for index: Int, width: CGFloat) {
        guard index < items.count else { return }
        let removeThreshold: CGFloat = width * (2/3)

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

    func performOnTapEffect() {
        addOpacity = true
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            addOpacity = false
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
    struct PreviewItem: Identifiable, Equatable {
        let id = UUID()
        let name: String
    }

    struct PreviewWrapper: View {
        @State var mockItems: [PreviewItem] = [
            PreviewItem(name: "Sample Item 1"),
            PreviewItem(name: "Sample Item 2"),
            PreviewItem(name: "Sample Item 3")
        ]
        @State var selection: PreviewItem?

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        MUCustomVerticalForEach(items: $mockItems,
                                                selection: $selection,
                                                deleteTitle: "Delete") { item in
                            Text(item.name)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
    return PreviewWrapper()
}
