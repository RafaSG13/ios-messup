//
//  DebtsServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 19/11/26.
//

import Foundation
import SwiftUI

/// People the user lends to or borrows from, and the loans, borrowings and repayments with them.
protocol DebtsServiceProtocol: AnyObject {
    /// Sorted by name.
    var people: [Person] { get }
    /// Sorted by date, oldest first.
    var entries: [DebtEntry] { get }

    func load() async throws
    func addPerson(_ person: Person) async throws
    /// Unknown ids are ignored.
    func updatePerson(with newValue: Person) async throws
    /// Also deletes the person's entries.
    func deletePerson(_ person: Person) async throws
    func addEntry(_ entry: DebtEntry) async throws
    /// Unknown ids are ignored.
    func updateEntry(with newValue: DebtEntry) async throws
    func deleteEntry(_ entry: DebtEntry) async throws
    /// Oldest first.
    func entries(for person: Person) -> [DebtEntry]
    func person(withContactIdentifier id: String) -> Person?
    /// Positive: the person owes the user. Negative: the user owes the person.
    func balance(of person: Person) -> Double
}

// MARK: - DebtsError

enum DebtsError: LocalizedError, Equatable {
    case invalidName
    case duplicateContact
    case invalidAmount
    case unknownPerson

    var errorDescription: String? {
        switch self {
        case .invalidName: String(localized: "Enter a name.")
        case .duplicateContact: String(localized: "That contact is already in your list.")
        case .invalidAmount: String(localized: "The amount must be greater than zero.")
        case .unknownPerson: String(localized: "This person no longer exists.")
        }
    }
}

// MARK: - Validation

extension DebtsError {
    /// Shared by the real service, the mock and the assistant so the rules live in one place.
    static func validate(_ person: Person, existing: [Person]) throws {
        guard !person.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw DebtsError.invalidName }
        if let contactIdentifier = person.contactIdentifier,
           existing.contains(where: { $0.contactIdentifier == contactIdentifier && $0.id != person.id }) {
            throw DebtsError.duplicateContact
        }
    }

    static func validate(_ entry: DebtEntry, people: [Person]) throws {
        guard entry.amount > 0 else { throw DebtsError.invalidAmount }
        guard people.contains(where: { $0.id == entry.personID }) else { throw DebtsError.unknownPerson }
    }
}

extension EnvironmentValues {
    @Entry var debtsService: DebtsServiceProtocol = defaultDebtsService
    // A `static let`: the macro's getter runs on every fallback read, so `MockDebtsService()` there would allocate a new service each time.
    private static let defaultDebtsService = MockDebtsService()
}
