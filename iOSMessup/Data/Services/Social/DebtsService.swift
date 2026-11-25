//
//  DebtsService.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

@Observable
final class DebtsService: DebtsServiceProtocol {
    private(set) var people: [Person] = []
    private(set) var entries: [DebtEntry] = []

    private let store: LocalStore

    init(store: LocalStore) {
        self.store = store
    }

    func load() async throws {
        try reloadPeople()
        try reloadEntries()
    }

    func addPerson(_ person: Person) async throws {
        try DebtsError.validate(person, existing: people)
        var person = person
        person.name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = store.context
        context.insert(PersonRecord(person))
        try context.save()
        try reloadPeople()
    }

    func updatePerson(with newValue: Person) async throws {
        try DebtsError.validate(newValue, existing: people)
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<PersonRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        var person = newValue
        person.name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        record.apply(person)
        try context.save()
        try reloadPeople()
    }

    func deletePerson(_ person: Person) async throws {
        let context = store.context
        let id = person.id
        let entryRecords = try context.fetch(FetchDescriptor<DebtEntryRecord>(predicate: #Predicate { $0.personID == id }))
        entryRecords.forEach { context.delete($0) }
        let personRecords = try context.fetch(FetchDescriptor<PersonRecord>(predicate: #Predicate { $0.id == id }))
        personRecords.forEach { context.delete($0) }
        try context.save()
        try reloadPeople()
        try reloadEntries()
    }

    func addEntry(_ entry: DebtEntry) async throws {
        try DebtsError.validate(entry, people: people)
        let context = store.context
        context.insert(DebtEntryRecord(entry))
        try context.save()
        try reloadEntries()
    }

    func updateEntry(with newValue: DebtEntry) async throws {
        try DebtsError.validate(newValue, people: people)
        let context = store.context
        let id = newValue.id
        var descriptor = FetchDescriptor<DebtEntryRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return }
        record.apply(newValue)
        try context.save()
        try reloadEntries()
    }

    func deleteEntry(_ entry: DebtEntry) async throws {
        let context = store.context
        let id = entry.id
        let records = try context.fetch(FetchDescriptor<DebtEntryRecord>(predicate: #Predicate { $0.id == id }))
        records.forEach { context.delete($0) }
        try context.save()
        try reloadEntries()
    }

    // MARK: - Persistence

    private func reloadPeople() throws {
        people = try store.context.fetch(FetchDescriptor<PersonRecord>()).map(\.domain).sorted()
    }

    private func reloadEntries() throws {
        let descriptor = FetchDescriptor<DebtEntryRecord>(sortBy: [SortDescriptor(\.date)])
        entries = try store.context.fetch(descriptor).map(\.domain)
    }

    // MARK: - Derived

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
