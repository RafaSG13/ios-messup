//
//  AllDepositsView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 2/2/25.
//

import SwiftUI

struct AllDepositsView: View {
    @Environment(\.incomeService) var incomeService
    @State private var selectedItem: Deposit?
    @State private var shouldPresentEditDeposit = false
    @State private var shouldPresentAddDeposit = false
    @State private var searchText = ""
    
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
                Task {
                    try await incomeService.deleteDeposits(removeAt: indexSet)
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
                    Image(systemName: "plus")
                }.buttonStyle(.plain)
            }
        }
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
