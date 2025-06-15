//
//  DepositSheetViewModifier.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI

//MARK: - AddDepositSheetModifier

struct AddDepositSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onSubmit: (Deposit) async throws -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                AddDepositViewModal() { deposit in
                    try await onSubmit(deposit)
                }
            }
    }
}

extension View {
    func addDepositSheet(isPresented: Binding<Bool>, onSubmit: @escaping (Deposit) async throws -> Void) -> some View {
        modifier(AddDepositSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }
}

//MARK: - EditDepositSheetModifier

struct EditDepositSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selectedDeposit: Deposit?
    var onSubmit: (Deposit) async throws -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: resetSelectedDeposit) {
                if let selectedDeposit {
                    EditDepositModalView(deposit: selectedDeposit) { deposit in
                        try await onSubmit(deposit)
                    }
                } else { Text("No deposit selected") }
            }
    }
    
    private func resetSelectedDeposit() {
        selectedDeposit = nil
    }
}

extension View {
    func editDepositSheet(isPresented: Binding<Bool>, selectedDeposit: Binding<Deposit?>, onSubmit: @escaping (Deposit) async throws -> Void) -> some View {
        modifier(EditDepositSheetModifier(isPresented: isPresented, selectedDeposit: selectedDeposit, onSubmit: onSubmit))
    }
}
