//
//  ResetTabViewModifiers.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/6/25.
//

import SwiftUI

private extension EnvironmentValues {
    @Entry var tabResetTrigger: Binding<Bool>? = nil
}

private struct ResettableTabViewContainer: ViewModifier {
    @Binding var shouldReset: Bool

    func body(content: Content) -> some View {
        content
            .environment(\.tabResetTrigger, $shouldReset)
    }
}

private struct TabResetAction<SelectionValue: Hashable>: ViewModifier {
    @Binding var selection: SelectionValue
    let firstTabTag: SelectionValue

    @Environment(\.tabResetTrigger) private var resetTrigger

    func body(content: Content) -> some View {
        content
            .onChange(of: resetTrigger?.wrappedValue) { oldValue, newValue in
                guard newValue == true else { return }
                selection = firstTabTag
                resetTrigger?.wrappedValue = false
            }
    }
}

extension View {
    func allowsTabReset(triggeredBy resetSignal: Binding<Bool>) -> some View {
        self.modifier(ResettableTabViewContainer(shouldReset: resetSignal))
    }

    func resettable<SelectionValue: Hashable>(selection: Binding<SelectionValue>, firstTabTag: SelectionValue) -> some View {
        self.modifier(TabResetAction(selection: selection, firstTabTag: firstTabTag))
    }
}
