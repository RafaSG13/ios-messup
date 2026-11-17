//
//  AllDepositsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI
import MUDesignSystem

struct AllDepositsView: View {
    @Environment(\.incomeService) var incomeService
    @State private var selectedItem: Deposit?
    @State private var shouldPresentEditDeposit = false
    @State private var shouldPresentAddDeposit = false
    @State private var searchText = ""
    @State private var error: (any Error)?

    var body: some View {
        List {
            ForEach(incomeService.filteredDeposits(on: searchText)) { deposit in
                DepositCellView(deposit: deposit)
                    .selectableCell {
                        selectedItem = deposit
                    }
                    .onChange(of: selectedItem) { _, newValue in
                        shouldPresentEditDeposit = newValue != nil
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 7.5, leading: 20, bottom: 7.5, trailing: 20))
            }.onDelete { indexSet in
                let displayed = incomeService.filteredDeposits(on: searchText)
                let depositsToDelete = indexSet.map { displayed[$0] }
                Task {
                    do {
                        for deposit in depositsToDelete {
                            try await incomeService.deleteDeposit(deposit)
                        }
                    } catch {
                        self.error = error
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .toolbar)
        .scrollIndicators(.hidden)
        .navigationTitle("All Deposits")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    shouldPresentAddDeposit = true
                } label: {
                    Label("Add deposit", systemImage: "plus")
                }.buttonStyle(.plain)
            }
        }
        .errorAlert($error)
        .editDepositSheet(isPresented: $shouldPresentEditDeposit, selectedDeposit: $selectedItem) { deposit in
            try await incomeService.updateDeposit(with: deposit)
        }
        .addDepositSheet(isPresented: $shouldPresentAddDeposit) { deposit in
            try await incomeService.createDeposit(deposit)
        }
    }
}

#Preview {
    NavigationStack {
        AllDepositsView()
    }
}
