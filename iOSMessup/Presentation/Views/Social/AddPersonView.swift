//
//  AddPersonView.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import ContactsUI
import SwiftUI

// MARK: - AddPersonView

/// Picks a person from Contacts (when allowed) or by typing a name. `onSelect` decides what happens with the person;
/// the sheet closes only when it succeeds.
struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.contactsService) private var contactsService
    @Environment(\.scenePhase) private var scenePhase
    @State private var authorization: ContactsAuthorization
    @State private var query = ""
    @State private var contacts: [ContactSummary] = []
    @State private var error: (any Error)?

    let onSelect: (Person) async throws -> Void

    init(contactsAuthorization: ContactsAuthorization, onSelect: @escaping (Person) async throws -> Void) {
        _authorization = State(initialValue: contactsAuthorization)
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            Form {
                ContactsAccessSection(authorization: $authorization)
                if authorization == .authorized || authorization == .limited {
                    ContactResultsSection(contacts: contacts,
                                          query: query,
                                          isLimited: authorization == .limited,
                                          onChoose: { choose(Person(name: $0.name, contactIdentifier: $0.id)) },
                                          onGranted: reloadContacts)
                }
                ManualPersonSection { choose(Person(name: $0, contactIdentifier: nil)) }
            }
            .modifier(ContactSearchModifier(isEnabled: authorization == .authorized || authorization == .limited,
                                            text: $query))
            .navigationTitle("Add person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .errorAlert($error)
            .task { authorization = contactsService.authorization }
            .task(id: SearchKey(query: query, authorization: authorization)) {
                contacts = await contactsService.search(query)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { authorization = contactsService.authorization }
            }
        }
    }
}

// MARK: - Actions

private extension AddPersonView {
    func choose(_ person: Person) {
        Task {
            do {
                try await onSelect(person)
                dismiss()
            } catch {
                self.error = error
            }
        }
    }

    /// `ContactAccessButton` just granted access to more contacts: show them.
    func reloadContacts(granted ids: [String]) {
        Task {
            let found = await contactsService.search(query)
            let added = await contactsService.contacts(withIdentifiers: ids).filter { !found.contains($0) }
            contacts = (found + added).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }
    }
}

// MARK: - SearchKey

private struct SearchKey: Hashable {
    let query: String
    let authorization: ContactsAuthorization
}

extension ContactsAuthorization: Hashable {}

// MARK: - ContactSearchModifier

/// The search field only makes sense once Contacts can be read.
private struct ContactSearchModifier: ViewModifier {
    let isEnabled: Bool
    @Binding var text: String

    func body(content: Content) -> some View {
        if isEnabled {
            content.searchable(text: $text, prompt: "Search contacts")
        } else {
            content
        }
    }
}

// MARK: - ContactsAccessSection

private struct ContactsAccessSection: View {
    @Environment(\.contactsService) private var contactsService
    @Environment(\.openURL) private var openURL
    @Binding var authorization: ContactsAuthorization

    var body: some View {
        switch authorization {
        case .notDetermined:
            Section {
                Text("Messup can show your contacts so you can pick who you lend to or borrow from. Contacts stay on your device.")
                Button("Allow access to contacts") {
                    Task { authorization = await contactsService.requestAccess() }
                }
            }
        case .denied:
            Section {
                Text("Contacts access is off. Allow it in Settings or type a name below.")
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
            }
        case .authorized, .limited:
            EmptyView()
        }
    }
}

// MARK: - ContactResultsSection

private struct ContactResultsSection: View {
    let contacts: [ContactSummary]
    let query: String
    let isLimited: Bool
    let onChoose: (ContactSummary) -> Void
    let onGranted: ([String]) -> Void

    var body: some View {
        Section("Contacts") {
            if isLimited {
                ContactAccessButton(queryString: query, approvalCallback: onGranted)
            }
            if contacts.isEmpty {
                if !query.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .clearListRow()
                }
            } else {
                ForEach(contacts) { contact in
                    Button {
                        onChoose(contact)
                    } label: {
                        Label(contact.name, systemImage: "person.crop.circle")
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }
}

// MARK: - ManualPersonSection

private struct ManualPersonSection: View {
    @State private var name = ""
    let onAdd: (String) -> Void

    var body: some View {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        Section("Not in your contacts") {
            TextField("Name", text: $name)
            Button("Add") { onAdd(trimmed) }
                .disabled(trimmed.isEmpty)
        }
    }
}

// MARK: - Preview

#Preview("Authorized") {
    AddPersonView(contactsAuthorization: .authorized) { _ in }
}

#Preview("Not determined") {
    AddPersonView(contactsAuthorization: .notDetermined) { _ in }
        .environment(\.contactsService, MockContactsService(authorization: .notDetermined, delay: 0))
}

#Preview("Denied") {
    AddPersonView(contactsAuthorization: .denied) { _ in }
        .environment(\.contactsService, MockContactsService(authorization: .denied, delay: 0))
}

#Preview("Limited") {
    AddPersonView(contactsAuthorization: .limited) { _ in }
        .environment(\.contactsService, MockContactsService(authorization: .limited, delay: 0))
}
