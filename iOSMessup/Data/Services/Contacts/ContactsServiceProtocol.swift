//
//  ContactsServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
import SwiftUI

/// A contact reduced to what Messup stores: the `CNContact.identifier` and a display name.
nonisolated struct ContactSummary: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
}

/// `.restricted` (parental controls, MDM) is reported as `.denied`.
enum ContactsAuthorization: Equatable {
    case notDetermined
    case denied
    case limited
    case authorized
}

protocol ContactsServiceProtocol: AnyObject {
    var authorization: ContactsAuthorization { get }
    /// Shows the system prompt only while `.notDetermined`. Returns the resulting state.
    func requestAccess() async -> ContactsAuthorization
    /// Contacts whose name contains `query` (all of them for an empty query), sorted by name. Unnamed contacts are
    /// omitted. Empty without access.
    func search(_ query: String) async -> [ContactSummary]
    /// Resolves identifiers, e.g. the ones `ContactAccessButton` just granted.
    func contacts(withIdentifiers ids: [String]) async -> [ContactSummary]
}

extension EnvironmentValues {
    @Entry var contactsService: ContactsServiceProtocol = MockContactsService()
}
