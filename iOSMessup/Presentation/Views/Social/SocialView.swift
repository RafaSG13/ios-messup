//
//  SocialView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - SocialRoute

private enum SocialRoute: Hashable {
    case person(String)
}

// MARK: - SocialView

/// Money lent to and borrowed from people. Owns the screen state; the lists read the service in child sections.
struct SocialView: View {
    @Environment(\.debtsService) private var debtsService
    @Environment(\.contactsService) private var contactsService
    @State private var path: [SocialRoute] = []
    @State private var isAddingPerson = false
    @State private var personToDelete: Person?
    @State private var error: (any Error)?

    var body: some View {
        NavigationStack(path: $path) {
            List {
                DebtSummarySection(isAddingPerson: $isAddingPerson)
                PeopleSection(personToDelete: $personToDelete)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(MUSpacer.size04)
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SocialRoute.self) { route in
                switch route {
                case .person(let id): PersonDetailView(personID: id)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add person", systemImage: "plus") {
                        isAddingPerson = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .errorAlert($error)
            .deletePersonDialog(person: $personToDelete, error: $error)
            .sheet(isPresented: $isAddingPerson) {
                AddPersonView(contactsAuthorization: contactsService.authorization, onSelect: choose)
            }
        }
    }
}

// MARK: - Actions

private extension SocialView {
    /// A contact that is already in the list opens that person instead of creating a duplicate.
    func choose(_ person: Person) async throws {
        if let contactIdentifier = person.contactIdentifier,
           let existing = debtsService.person(withContactIdentifier: contactIdentifier) {
            path.append(.person(existing.id))
        } else {
            try await debtsService.addPerson(person)
            path.append(.person(person.id))
        }
    }
}

// MARK: - DebtSummarySection

private struct DebtSummarySection: View {
    @Environment(\.debtsService) private var debtsService
    @Environment(\.currencyCode) private var currencyCode
    @Binding var isAddingPerson: Bool

    var body: some View {
        let summary = DebtSummary(people: debtsService.people, entries: debtsService.entries)
        Section {
            if debtsService.people.isEmpty {
                MUEmptyState("No debts",
                             systemImage: "person.2",
                             description: "Add a person to track money you lend or borrow.",
                             actionTitle: "Add person") {
                    isAddingPerson = true
                }
                .clearListRow()
            } else {
                MUCard {
                    VStack(alignment: .leading, spacing: MUSpacer.size01) {
                        MUHeroAmount(abs(summary.net).formattedMoney(code: currencyCode), value: abs(summary.net))
                        Text(netCaption(summary.net))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    MUAdaptiveStack {
                        MUStatTile("They owe you", value: summary.owedToMe.formattedMoney(code: currencyCode))
                        MUStatTile("You owe", value: summary.iOwe.formattedMoney(code: currencyCode))
                    }
                }
                .clearListRow(insets: EdgeInsets())
            }
        }
    }

    private func netCaption(_ net: Double) -> LocalizedStringKey {
        if abs(net) < DebtSummary.settledTolerance { "all settled" } else if net > 0 { "net owed to you" } else { "net you owe" }
    }
}

// MARK: - PeopleSection

private struct PeopleSection: View {
    @Environment(\.debtsService) private var debtsService
    @Binding var personToDelete: Person?

    var body: some View {
        let balances = DebtSummary(people: debtsService.people, entries: debtsService.entries).balances
        if !balances.isEmpty {
            Section {
                ForEach(balances) { item in
                    NavigationLink(value: SocialRoute.person(item.person.id)) {
                        PersonCellView(item: item)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // Not `role: .destructive`: the row is not removed until the user confirms, and UIKit expects a
                        // destructive swipe action to remove its row at once.
                        Button("Delete") { personToDelete = item.person }
                            .tint(Color.designSystem.critical)
                    }
                }
            } header: {
                Text("People")
                    .textCase(nil)
            }
        }
    }
}

// MARK: - Preview

#Preview("Mock data") {
    SocialView()
}

#Preview("Empty") {
    SocialView()
        .environment(\.debtsService, MockDebtsService(initialPeople: [], initialEntries: [], delay: 0))
}

#Preview("Failing service") {
    SocialView()
        .environment(\.debtsService, MockDebtsService(delay: 0, shouldFail: true))
}
