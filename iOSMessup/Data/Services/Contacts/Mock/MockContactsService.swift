//
//  MockContactsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation

final class MockContactsService: ContactsServiceProtocol {
    private(set) var authorization: ContactsAuthorization
    var contacts: [ContactSummary]
    var delay: TimeInterval

    init(authorization: ContactsAuthorization = .authorized,
         contacts: [ContactSummary] = [ContactSummary(id: "contact-1", name: "Alex Rivera"),
                                       ContactSummary(id: "contact-2", name: "Pedro Test"),
                                       ContactSummary(id: "contact-3", name: "Taylor Morgan")],
         delay: TimeInterval = 0.1) {
        self.authorization = authorization
        self.contacts = contacts
        self.delay = delay
    }

    func requestAccess() async -> ContactsAuthorization {
        try? await Task.sleep(for: .seconds(delay))
        authorization = .authorized
        return authorization
    }

    func search(_ query: String) async -> [ContactSummary] {
        try? await Task.sleep(for: .seconds(delay))
        guard authorization == .authorized || authorization == .limited else { return [] }
        return contacts
            .filter { query.isEmpty || $0.name.localizedStandardContains(query) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func contacts(withIdentifiers ids: [String]) async -> [ContactSummary] {
        try? await Task.sleep(for: .seconds(delay))
        return contacts.filter { ids.contains($0.id) }
    }
}
