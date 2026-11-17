//
//  SelectableCell.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 26/1/25.
//

import SwiftUI

//MARK: - Selectable Cell ViewModifier

public struct SelectableCell: ViewModifier {

    var onTap: () -> Void

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public func body(content: Content) -> some View {
        Button {
            onTap()
        } label: {
            content
        }
    }
}
