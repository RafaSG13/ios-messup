//
//  ErrorAlertModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI

// MARK: - ErrorAlertModifier

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: (any Error)?

    func body(content: Content) -> some View {
        content
            .alert("Something went wrong", isPresented: isPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(error?.localizedDescription ?? "")
            }
    }

    private var isPresented: Binding<Bool> {
        Binding(get: { error != nil },
                set: { if !$0 { error = nil } })
    }
}

extension View {
    /// Shows an alert while `error` is non-nil and clears it on dismiss.
    func errorAlert(_ error: Binding<(any Error)?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewError: LocalizedError {
        var errorDescription: String? { "The expense could not be saved." }
    }

    return Text("Content")
        .errorAlert(.constant(PreviewError()))
}
