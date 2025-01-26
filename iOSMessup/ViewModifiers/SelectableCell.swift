//
//  SelectableCell.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 26/1/25.
//

import SwiftUI

//MARK: - Selectable Cell ViewModifier

struct SelectableCell<Item: Equatable>: ViewModifier {

    @Binding var selectedItem: Item?
    var ownItem: Item
    var onTap: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .overlay {
                Color.black.opacity(isSelected() ? 0.2 : 0)
            }.onTapGesture {
                selectedItem = ownItem
                onTap?()
            }.onLongPressGesture {
                selectedItem = ownItem
                onTap?()
            }
            .animation(.easeIn, value: selectedItem)
    }

    func isSelected() -> Bool {
        guard let selectedItem else { return false }
        return selectedItem == ownItem
    }
}
