//
//  PersonDetailView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - PersonDetailView

/// Balance and history with one person. Owns the screen state (sheets, rename, delete); the data reads live in the
/// child sections.
struct PersonDetailView: View {
    @Environment(\.debtsService) private var debtsService
    @Environment(\.dismiss) private var dismiss
    let personID: String
    @State private var formMode: DebtEntryFormView.Mode?
    @State private var isRenaming = false
    @State private var newName = ""
    @State private var personToDelete: Person?
    @State private var error: (any Error)?

    var body: some View {
        Group {
            if let person = debtsService.people.first(where: { $0.id == personID }) {
                List {
                    PersonBalanceSection(person: person, formMode: $formMode)
                    DebtHistorySection(person: person, formMode: $formMode, error: $error)
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(MUSpacer.size04)
                .navigationTitle(person.name)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu("Person options", systemImage: "ellipsis") {
                            Button("Rename", systemImage: "pencil") {
                                newName = person.name
                                isRenaming = true
                            }
                            Button("Delete person", systemImage: "trash", role: .destructive) {
                                personToDelete = person
                            }
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add entry", systemImage: "plus") {
                            formMode = .add(personID: person.id)
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
                .alert("Rename", isPresented: $isRenaming) {
                    TextField("Name", text: $newName)
                    Button("Save") { rename(person) }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                ContentUnavailableView("Person not found", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
        .errorAlert($error)
        .debtEntrySheet(mode: $formMode, onSubmit: submit)
        .deletePersonDialog(person: $personToDelete, error: $error) { dismiss() }
    }
}

// MARK: - Actions

private extension PersonDetailView {
    func rename(_ person: Person) {
        var renamed = person
        renamed.name = newName
        Task {
            do {
                try await debtsService.updatePerson(with: renamed)
            } catch {
                self.error = error
            }
        }
    }

    /// The form keeps the entry `id` when editing, so a matching id means update, anything else is a new entry.
    func submit(_ entry: DebtEntry) async throws {
        if debtsService.entries.contains(where: { $0.id == entry.id }) {
            try await debtsService.updateEntry(with: entry)
        } else {
            try await debtsService.addEntry(entry)
        }
    }
}

// MARK: - PersonBalanceSection

private struct PersonBalanceSection: View {
    @Environment(\.debtsService) private var debtsService
    let person: Person
    @Binding var formMode: DebtEntryFormView.Mode?

    var body: some View {
        let entries = debtsService.entries(for: person)
        let balance = DebtSummary.balance(of: person.id, in: entries)
        Section {
            PersonBalanceCard(personID: person.id,
                              balance: balance,
                              debts: entries.filter { !$0.kind.isPayment }.reduce(0) { $0 + $1.amount },
                              payments: entries.filter { $0.kind.isPayment }.reduce(0) { $0 + $1.amount },
                              formMode: $formMode)
                .clearListRow(insets: EdgeInsets())
        }
    }
}

// MARK: - PersonBalanceCard

private struct PersonBalanceCard: View {
    @Environment(\.currencyCode) private var currencyCode
    let personID: String
    let balance: Double
    let debts: Double
    let payments: Double
    @Binding var formMode: DebtEntryFormView.Mode?

    var body: some View {
        let isSettled = abs(balance) < DebtSummary.settledTolerance
        MUCard {
            VStack(alignment: .leading, spacing: MUSpacer.size01) {
                MUHeroAmount(abs(balance).formattedMoney(code: currencyCode), value: abs(balance))
                Text(isSettled ? "all settled" : (balance > 0 ? "owes you" : "you owe"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            MUAdaptiveStack {
                MUStatTile("Debts", value: debts.formattedCompactMoney(code: currencyCode))
                MUStatTile("Payments", value: payments.formattedCompactMoney(code: currencyCode))
            }
            if !isSettled {
                Button {
                    formMode = .add(personID: personID,
                                    kind: balance > 0 ? .receivedPayment : .madePayment,
                                    amount: abs(balance))
                } label: {
                    Text("Settle up").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

// MARK: - DebtHistorySection

private struct DebtHistorySection: View {
    @Environment(\.debtsService) private var debtsService
    let person: Person
    @Binding var formMode: DebtEntryFormView.Mode?
    @Binding var error: (any Error)?

    var body: some View {
        let sections = debtsService.entries(for: person).groupedByDay(date: \.date)
        if sections.isEmpty {
            Section {
                MUEmptyState("No history",
                             systemImage: "clock",
                             description: "Add a debt or a payment to start the history.",
                             actionTitle: "Add entry") {
                    formMode = .add(personID: person.id)
                }
                .clearListRow()
            }
        }
        ForEach(sections) { section in
            Section {
                ForEach(section.items) { entry in
                    DebtEntryListRow(entry: entry, formMode: $formMode, error: $error)
                }
            } header: {
                Text(section.day, format: .dateTime.weekday(.wide).day().month(.wide).year())
            }
        }
    }
}

// MARK: - DebtEntryListRow

private struct DebtEntryListRow: View {
    @Environment(\.debtsService) private var debtsService
    let entry: DebtEntry
    @Binding var formMode: DebtEntryFormView.Mode?
    @Binding var error: (any Error)?

    var body: some View {
        DebtEntryCellView(entry: entry)
            .selectableCell { formMode = .edit(entry) }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete", role: .destructive, action: delete)
            }
    }

    private func delete() {
        Task {
            do {
                try await debtsService.deleteEntry(entry)
            } catch {
                self.error = error
            }
        }
    }
}

// MARK: - Previews

#Preview("With history") {
    NavigationStack {
        PersonDetailView(personID: "mock-alex")
    }
}

#Preview("No history") {
    NavigationStack {
        PersonDetailView(personID: "mock-alex")
    }
    .environment(\.debtsService, MockDebtsService(initialEntries: [], delay: 0))
}

#Preview("Settled") {
    NavigationStack {
        PersonDetailView(personID: "mock-jordan")
    }
}

#Preview("Failing service") {
    NavigationStack {
        PersonDetailView(personID: "mock-alex")
    }
    .environment(\.debtsService, MockDebtsService(delay: 0, shouldFail: true))
}

#Preview("Unknown person") {
    NavigationStack {
        PersonDetailView(personID: "missing")
    }
}
