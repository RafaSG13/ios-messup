//
//  SelectableCell.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 26/1/25.
//

import SwiftUI

//MARK: - Selectable Cell ViewModifier

struct SelectableCell: ViewModifier {

    var onTap: () -> Void

    func body(content: Content) -> some View {
        Button {
            onTap()
        } label: {
            content
        }
    }
}
