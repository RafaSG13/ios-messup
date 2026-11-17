//
//  DebugSection.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import SwiftUI

struct DebugSection: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.incomeService) private var incomeService
    @AppStorage(DebugSeeder.autoSeedKey) private var isAutoSeedOn = true
    @State private var isConfirmingDelete = false
    @State private var error: (any Error)?

    private var isLocal: Bool { MUEnvironmentConfigurator.current == .local }

    var body: some View {
        Section("Debug") {
            LabeledContent("Environment", value: MUEnvironmentConfigurator.current.rawValue)
            if isLocal {
                Toggle("Auto-seed when empty", isOn: $isAutoSeedOn)
                Button("Replace with sample data") {
                    run { try DebugSeeder.replaceWithSampleData(in: .shared) }
                }
                Button("Delete all data", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .confirmationDialog("Delete all data?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) {
                run { try DebugSeeder.deleteAllData(in: .shared) }
            }
        }
        .errorAlert($error)
    }

    // MARK: - Actions

    private func run(_ change: @escaping @MainActor () throws -> Void) {
        Task {
            do {
                try change()
                try await expenseService.loadExpenses()
                try await incomeService.load()
            } catch {
                self.error = error
            }
        }
    }
}

#Preview {
    List { DebugSection() }
}
#endif
