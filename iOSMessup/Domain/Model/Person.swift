//
//  Person.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation

/// Someone the user lends money to or borrows from. `contactIdentifier` is the `CNContact.identifier` the person was
/// picked from; `nil` means the name was typed by hand. The name is a copy and is not refreshed from Contacts.
struct Person: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var contactIdentifier: String?
}

// MARK: - Comparable Conformance

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

// MARK: - Mocks

extension Person {
    static var mock = Person(id: "mock-alex", name: "Alex Rivera")

    static var mockArray: [Person] = [
        Person(id: "mock-alex", name: "Alex Rivera"),
        Person(id: "mock-sam", name: "Sam Carter"),
        Person(id: "mock-jordan", name: "Jordan Lee")
    ]
}
