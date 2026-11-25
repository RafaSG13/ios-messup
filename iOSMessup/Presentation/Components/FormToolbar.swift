//
//  FormToolbar.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 25/11/26.
//

import SwiftUI

// MARK: - FormToolbar

/// Cancel / Save / keyboard Done shared by every add-edit form.
struct FormToolbar: ToolbarContent {
    let isSaveDisabled: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: onCancel)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", role: .confirm, action: onSave)
                .disabled(isSaveDisabled)
        }
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done") { UIApplication.shared.hideKeyboard() }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        Form {
            TextField("Name", text: .constant(""))
        }
        .toolbar {
            FormToolbar(isSaveDisabled: true, onCancel: {}, onSave: {})
        }
    }
}
