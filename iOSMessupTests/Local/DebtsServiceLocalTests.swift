//
//  DebtsServiceLocalTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct DebtsServiceLocalTests {
    private let alex = Person(name: "Alex Rivera")
    private let sam = Person(name: "Sam Carter", contactIdentifier: "contact-sam")

    private func entry(_ person: Person, _ kind: DebtEntryKind = .lent, _ amount: Double = 10, daysAgo: Int = 0) -> DebtEntry {
        DebtEntry(personID: person.id, kind: kind, amount: amount,
                  date: Date(timeIntervalSince1970: 1_700_000_000 - Double(daysAgo) * 86_400))
    }

    @Test func peopleAndEntriesPersistAcrossServices() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = DebtsService(store: store)
        try await service.addPerson(sam)
        try await service.addPerson(alex)
        let lent = entry(alex, .lent, 25)
        try await service.addEntry(lent)

        let other = DebtsService(store: store)
        try await other.load()

        #expect(other.people.map(\.name) == ["Alex Rivera", "Sam Carter"])
        #expect(other.entries == [lent])
        #expect(other.person(withContactIdentifier: "contact-sam")?.id == sam.id)
    }

    @Test func updatesPersistAndKeepTheId() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = DebtsService(store: store)
        try await service.addPerson(alex)
        let original = entry(alex)
        try await service.addEntry(original)

        var renamed = alex
        renamed.name = "  Alexandra  "
        try await service.updatePerson(with: renamed)
        var edited = original
        edited.amount = 99
        edited.kind = .borrowed
        try await service.updateEntry(with: edited)

        let other = DebtsService(store: store)
        try await other.load()
        #expect(other.people.map(\.name) == ["Alexandra"])
        #expect(other.entries.map(\.amount) == [99])
        #expect(other.balance(of: alex) == -99)
    }

    @Test func deletingAPersonDeletesOnlyTheirEntries() async throws {
        let store = LocalStore(storage: .inMemory)
        let service = DebtsService(store: store)
        try await service.addPerson(alex)
        try await service.addPerson(sam)
        try await service.addEntry(entry(alex))
        try await service.addEntry(entry(alex, .receivedPayment, 5))
        let samEntry = entry(sam, .borrowed, 40)
        try await service.addEntry(samEntry)

        try await service.deletePerson(alex)

        let other = DebtsService(store: store)
        try await other.load()
        #expect(other.people == [sam])
        #expect(other.entries == [samEntry])
    }

    @Test func deletingAnEntryKeepsThePerson() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(alex)
        let first = entry(alex)
        try await service.addEntry(first)

        try await service.deleteEntry(first)

        #expect(service.entries.isEmpty)
        #expect(service.people == [alex])
    }

    @Test func entryForAnUnknownPersonIsRejected() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))

        await #expect(throws: DebtsError.unknownPerson) { try await service.addEntry(entry(alex)) }
        #expect(service.entries.isEmpty)
    }

    @Test func nonPositiveAmountsAreRejected() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(alex)

        await #expect(throws: DebtsError.invalidAmount) { try await service.addEntry(entry(alex, .lent, 0)) }
        await #expect(throws: DebtsError.invalidAmount) { try await service.addEntry(entry(alex, .lent, -5)) }
        #expect(service.entries.isEmpty)
    }

    @Test func aContactCannotBeAddedTwice() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(sam)

        await #expect(throws: DebtsError.duplicateContact) {
            try await service.addPerson(Person(name: "Samuel", contactIdentifier: "contact-sam"))
        }
        #expect(service.people.count == 1)
    }

    @Test func blankNamesAreRejectedAndNamesAreTrimmed() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))

        await #expect(throws: DebtsError.invalidName) { try await service.addPerson(Person(name: "   ")) }
        try await service.addPerson(Person(name: "  Pedro  "))

        #expect(service.people.map(\.name) == ["Pedro"])
    }

    @Test func updatingUnknownIdsChangesNothing() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(alex)
        let existing = entry(alex)
        try await service.addEntry(existing)

        try await service.updatePerson(with: Person(name: "Ghost"))
        try await service.updateEntry(with: entry(alex, .borrowed, 77))

        #expect(service.people == [alex])
        #expect(service.entries == [existing])
    }

    @Test func entriesForAPersonAreOldestFirst() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(alex)
        try await service.addPerson(sam)
        let recent = entry(alex, daysAgo: 1)
        let old = entry(alex, daysAgo: 9)
        try await service.addEntry(recent)
        try await service.addEntry(entry(sam))
        try await service.addEntry(old)

        #expect(service.entries(for: alex) == [old, recent])
    }

    @Test func contactLookupFindsNothingForHandTypedPeople() async throws {
        let service = DebtsService(store: LocalStore(storage: .inMemory))
        try await service.addPerson(alex)

        #expect(service.person(withContactIdentifier: "contact-sam") == nil)
    }
}
