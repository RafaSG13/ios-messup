//
//  MockDebtsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class MockDebtsService: DebtsServiceProtocol {
    private(set) var people: [Person]
    private(set) var entries: [DebtEntry]
    var delay: TimeInterval
    var shouldFail: Bool

    init(initialPeople: [Person] = Person.mockArray,
         initialEntries: [DebtEntry] = DebtEntry.mockArray,
         delay: TimeInterval = 0.1,
         shouldFail: Bool = false) {
        self.people = initialPeople.sorted()
        self.entries = initialEntries.sorted()
        self.delay = delay
        self.shouldFail = shouldFail
    }

    private func simulateNetwork() async throws {
        try await Task.sleep(for: .seconds(delay))
        if shouldFail {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])
        }
    }

    func load() async throws {
        try await simulateNetwork()
    }

    func addPerson(_ person: Person) async throws {
        try await simulateNetwork()
        try DebtsError.validate(person, existing: people)
        var person = person
        person.name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        people.append(person)
        people.sort()
    }

    func updatePerson(with newValue: Person) async throws {
        try await simulateNetwork()
        try DebtsError.validate(newValue, existing: people)
        guard let index = people.firstIndex(where: { $0.id == newValue.id }) else { return }
        var person = newValue
        person.name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        people[index] = person
        people.sort()
    }

    func deletePerson(_ person: Person) async throws {
        try await simulateNetwork()
        entries.removeAll { $0.personID == person.id }
        people.removeAll { $0.id == person.id }
    }

    func addEntry(_ entry: DebtEntry) async throws {
        try await simulateNetwork()
        try DebtsError.validate(entry, people: people)
        entries.append(entry)
        entries.sort()
    }

    func updateEntry(with newValue: DebtEntry) async throws {
        try await simulateNetwork()
        try DebtsError.validate(newValue, people: people)
        guard let index = entries.firstIndex(where: { $0.id == newValue.id }) else { return }
        entries[index] = newValue
        entries.sort()
    }

    func deleteEntry(_ entry: DebtEntry) async throws {
        try await simulateNetwork()
        entries.removeAll { $0.id == entry.id }
    }

    func entries(for person: Person) -> [DebtEntry] {
        entries.filter { $0.personID == person.id }
    }

    func person(withContactIdentifier id: String) -> Person? {
        people.first { $0.contactIdentifier == id }
    }

    func balance(of person: Person) -> Double {
        DebtSummary.balance(of: person.id, in: entries)
    }
}
