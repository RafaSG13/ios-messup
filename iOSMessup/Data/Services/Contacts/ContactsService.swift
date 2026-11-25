//
//  ContactsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Contacts
import Foundation

/// Not `@Observable`: the views re-read `authorization` when they appear, after `requestAccess` and when the app
/// becomes active again.
final class ContactsService: ContactsServiceProtocol {
    var authorization: ContactsAuthorization {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .limited: .limited
        case .denied, .restricted: .denied
        @unknown default: .denied
        }
    }

    func requestAccess() async -> ContactsAuthorization {
        if authorization == .notDetermined {
            _ = try? await CNContactStore().requestAccess(for: .contacts)
        }
        return authorization
    }

    func search(_ query: String) async -> [ContactSummary] {
        guard authorization == .authorized || authorization == .limited else { return [] }
        return await Self.fetch(matching: query)
    }

    func contacts(withIdentifiers ids: [String]) async -> [ContactSummary] {
        guard !ids.isEmpty, authorization == .authorized || authorization == .limited else { return [] }
        return await Self.fetch(identifiers: ids)
    }

    // MARK: - Contacts framework

    /// `CNContact` never leaves these functions: only `Sendable` summaries do. Errors give an empty list, there is
    /// nothing the user could do about them.
    @concurrent
    private nonisolated static func fetch(matching query: String) async -> [ContactSummary] {
        let store = CNContactStore()
        let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
        var result: [ContactSummary] = []
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                guard let name = CNContactFormatter.string(from: contact, style: .fullName), !name.isEmpty else { return }
                if query.isEmpty || name.localizedStandardContains(query) {
                    result.append(ContactSummary(id: contact.identifier, name: name))
                }
            }
        } catch {
            return []
        }
        return result.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    @concurrent
    private nonisolated static func fetch(identifiers: [String]) async -> [ContactSummary] {
        let store = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        guard let contacts = try? store.unifiedContacts(matching: CNContact.predicateForContacts(withIdentifiers: identifiers),
                                                        keysToFetch: keys) else { return [] }
        return contacts.compactMap { contact in
            guard let name = CNContactFormatter.string(from: contact, style: .fullName), !name.isEmpty else { return nil }
            return ContactSummary(id: contact.identifier, name: name)
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
