//
//  AssistantActions.swift
//  iOSMessup
//

import Foundation

/// What the assistant's change tools do. Every method returns the text the model reads next and never throws:
/// failures come back as `"Error: …"` so the model can recover or ask the user. Creating and editing apply at once and
/// are announced through `record`; every deletion waits for `confirm`.
final class AssistantActions {
    typealias Confirm = (AssistantActionCenter.ConfirmationRequest) async -> Bool
    typealias Record = (AssistantActionCenter.ActionEvent) -> Void

    private let expenses: ExpensesServiceProtocol
    private let incomes: IncomeServiceProtocol
    private let budget: BudgetServiceProtocol
    private let debts: DebtsServiceProtocol
    private let currencyCode: () -> String
    private let now: () -> Date
    private let calendar: Calendar
    private let confirm: Confirm
    private let record: Record

    init(expenses: ExpensesServiceProtocol,
         incomes: IncomeServiceProtocol,
         budget: BudgetServiceProtocol,
         debts: DebtsServiceProtocol,
         currencyCode: @escaping () -> String,
         now: @escaping () -> Date = { .now },
         calendar: Calendar = .current,
         confirm: @escaping Confirm,
         record: @escaping Record) {
        self.expenses = expenses
        self.incomes = incomes
        self.budget = budget
        self.debts = debts
        self.currencyCode = currencyCode
        self.now = now
        self.calendar = calendar
        self.confirm = confirm
        self.record = record
    }

    // MARK: - Expenses

    func changeExpense(_ arguments: ExpenseChangeArguments) async -> String {
        do {
            switch arguments.action {
            case .create:
                let name = arguments.name.trimmed
                guard !name.isEmpty else { return Self.missing("name") }
                guard let amount = arguments.amount, amount > 0 else { return Self.missing("amount") }
                let expense = Expense(name: name,
                                      amount: amount,
                                      date: resolvedDate(arguments.date, arguments.daysAgo) ?? now(),
                                      paymentMethod: arguments.paymentMethod.map(PaymentMethod.init) ?? .other,
                                      category: arguments.category.map(Category.init) ?? .miscellaneous)
                try await expenses.addExpense(expense)
                return announce("Created expense", expense.id, describe(expense))

            case .update:
                var expense = try findExpense(arguments.ref)
                var changed = false
                if let name = arguments.name?.trimmed, !name.isEmpty { expense.name = name; changed = true }
                if let amount = arguments.amount {
                    guard amount > 0 else { return Self.invalidAmount }
                    expense.amount = amount
                    changed = true
                }
                if let date = resolvedDate(arguments.date, arguments.daysAgo) { expense.date = date; changed = true }
                if let method = arguments.paymentMethod { expense.paymentMethod = PaymentMethod(method); changed = true }
                if let category = arguments.category { expense.category = Category(category); changed = true }
                guard changed else { return Self.nothingToChange }
                try await expenses.updateExpense(with: expense)
                return announce("Updated expense", expense.id, describe(expense))

            case .delete:
                let expense = try findExpense(arguments.ref)
                let summary = "\(expense.name) · \(money(expense.amount)) · \(isoDay(expense.date))"
                guard await confirm(.init(title: String(localized: "Delete expense?"),
                                          details: [summary],
                                          confirmLabel: String(localized: "Delete"))) else { return Self.cancelled }
                try await expenses.delete(expense)
                return announce("Deleted expense", nil, describe(expense))
            }
        } catch {
            return Self.text(for: error)
        }
    }

    // MARK: - Income

    func changeIncome(_ arguments: IncomeChangeArguments) async -> String {
        do {
            switch arguments.action {
            case .create:
                let concept = arguments.concept.trimmed
                guard !concept.isEmpty else { return Self.missing("concept") }
                guard let amount = arguments.amount, amount > 0 else { return Self.missing("amount") }
                let income = Income(concept: concept,
                                    amount: amount,
                                    date: resolvedDate(arguments.date, arguments.daysAgo) ?? now(),
                                    source: arguments.source.map(IncomeSource.init) ?? .other)
                try await incomes.createIncome(income)
                return announce("Created income", income.id, describe(income))

            case .update:
                var income = try findIncome(arguments.ref)
                var changed = false
                if let concept = arguments.concept?.trimmed, !concept.isEmpty { income.concept = concept; changed = true }
                if let amount = arguments.amount {
                    guard amount > 0 else { return Self.invalidAmount }
                    income.amount = amount
                    changed = true
                }
                if let date = resolvedDate(arguments.date, arguments.daysAgo) { income.date = date; changed = true }
                if let source = arguments.source { income.source = IncomeSource(source); changed = true }
                guard changed else { return Self.nothingToChange }
                try await incomes.updateIncome(with: income)
                return announce("Updated income", income.id, describe(income))

            case .delete:
                let income = try findIncome(arguments.ref)
                let summary = "\(income.concept) · \(money(income.amount)) · \(isoDay(income.date))"
                guard await confirm(.init(title: String(localized: "Delete income?"),
                                          details: [summary],
                                          confirmLabel: String(localized: "Delete"))) else { return Self.cancelled }
                try await incomes.deleteIncome(income)
                return announce("Deleted income", nil, describe(income))
            }
        } catch {
            return Self.text(for: error)
        }
    }

    // MARK: - Budget

    func changeBudget(_ arguments: BudgetChangeArguments) async -> String {
        do {
            switch arguments.action {
            case .set:
                let monthly = arguments.monthlyLimit.flatMap { $0 > 0 ? $0 : nil }
                let categoryChange = arguments.category.flatMap { category in
                    arguments.categoryLimit.map { (Category(category), $0) }
                }
                guard monthly != nil || categoryChange != nil else {
                    return "Error: missing monthlyLimit, or category with categoryLimit. Ask the user."
                }
                if let (_, limit) = categoryChange, limit < 0 { return Self.invalidAmount }

                var updated: Budget
                if let existing = budget.budget {
                    updated = existing
                } else if let monthly {
                    updated = Budget(monthlyLimit: monthly)
                } else {
                    return "Error: set a monthly limit first."
                }
                if let monthly { updated.monthlyLimit = monthly }
                if let (category, limit) = categoryChange {
                    updated.categoryLimits[category] = limit == 0 ? nil : limit
                }
                try await budget.saveBudget(updated)
                let detail = "\(money(updated.monthlyLimit)) / month · \(updated.categoryLimits.count) category limits"
                record(.init(systemImage: "gauge.with.dots.needle.67percent",
                             title: String(localized: "Updated budget"),
                             detail: detail))
                return "Budget saved: \(detail)."

            case .clear:
                guard let current = budget.budget else { return "Error: there is no budget." }
                let details = [String(localized: "Monthly limit: \(money(current.monthlyLimit))"),
                               String(localized: "\(current.categoryLimits.count) category limits")]
                guard await confirm(.init(title: String(localized: "Delete budget?"),
                                          details: details,
                                          confirmLabel: String(localized: "Delete"))) else { return Self.cancelled }
                try await budget.deleteBudget()
                record(.init(systemImage: "trash",
                             title: String(localized: "Deleted budget"),
                             detail: money(current.monthlyLimit)))
                return "Deleted the budget."
            }
        } catch {
            return Self.text(for: error)
        }
    }

    // MARK: - People

    func changePerson(_ arguments: PersonChangeArguments) async -> String {
        do {
            let name = arguments.name.trimmed
            switch arguments.action {
            case .add:
                guard !name.isEmpty else { return Self.missing("name") }
                if debts.people.contains(where: { Self.sameName($0.name, name) }) {
                    return "Error: \(name) is already in the list."
                }
                let person = Person(name: name)
                try await debts.addPerson(person)
                record(.init(systemImage: "person.badge.plus", title: String(localized: "Added person"), detail: name))
                return "Added person \(name)."

            case .rename:
                guard let newName = arguments.newName?.trimmed, !newName.isEmpty else { return Self.missing("newName") }
                var person = try findPerson(named: name)
                let oldName = person.name
                person.name = newName
                try await debts.updatePerson(with: person)
                record(.init(systemImage: "pencil",
                             title: String(localized: "Renamed person"),
                             detail: "\(oldName) → \(newName)"))
                return "Renamed \(oldName) to \(newName)."

            case .delete:
                let person = try findPerson(named: name)
                let count = debts.entries(for: person).count
                let balance = debts.balance(of: person)
                let balanceText: String
                if abs(balance) < DebtSummary.settledTolerance {
                    balanceText = String(localized: "Balance: settled")
                } else if balance > 0 {
                    balanceText = String(localized: "Balance: owes you \(money(balance))")
                } else {
                    balanceText = String(localized: "Balance: you owe \(money(-balance))")
                }
                let details = [person.name, String(localized: "\(count) debts and payments"), balanceText]
                guard await confirm(.init(title: String(localized: "Delete person?"),
                                          details: details,
                                          confirmLabel: String(localized: "Delete"))) else { return Self.cancelled }
                try await debts.deletePerson(person)
                record(.init(systemImage: "trash", title: String(localized: "Deleted person"), detail: person.name))
                return "Deleted \(person.name) and \(count) entries."
            }
        } catch {
            return Self.text(for: error)
        }
    }

    // MARK: - Debts

    func changeDebt(_ arguments: DebtChangeArguments) async -> String {
        do {
            switch arguments.action {
            case .create:
                let name = arguments.personName.trimmed
                guard !name.isEmpty else { return Self.missing("personName") }
                guard let kind = arguments.kind else { return Self.missing("kind") }
                guard let amount = arguments.amount, amount > 0 else { return Self.missing("amount") }

                let matches = matchingPeople(named: name)
                guard matches.count <= 1 else { return Self.ambiguous(matches) }
                let person: Person
                if let existing = matches.first {
                    person = existing
                } else {
                    person = Person(name: name)
                    try await debts.addPerson(person)
                    record(.init(systemImage: "person.badge.plus", title: String(localized: "Added person"), detail: name))
                }
                let entry = DebtEntry(personID: person.id,
                                      kind: DebtEntryKind(kind),
                                      amount: amount,
                                      date: resolvedDate(arguments.date, arguments.daysAgo) ?? now(),
                                      note: arguments.note.trimmed)
                try await debts.addEntry(entry)
                return announce("Created debt", entry.id, describe(entry, person: person))

            case .update:
                var entry = try findEntry(arguments.ref)
                var changed = false
                if let kind = arguments.kind { entry.kind = DebtEntryKind(kind); changed = true }
                if let amount = arguments.amount {
                    guard amount > 0 else { return Self.invalidAmount }
                    entry.amount = amount
                    changed = true
                }
                if let date = resolvedDate(arguments.date, arguments.daysAgo) { entry.date = date; changed = true }
                if let note = arguments.note { entry.note = note.trimmed; changed = true }
                guard changed else { return Self.nothingToChange }
                try await debts.updateEntry(with: entry)
                return announce("Updated debt", entry.id, describe(entry, person: owner(of: entry)))

            case .delete:
                let entry = try findEntry(arguments.ref)
                let person = owner(of: entry)
                let details = [person?.name ?? "", "\(Self.kindText(entry.kind)) · \(money(entry.amount)) · \(isoDay(entry.date))"]
                    .filter { !$0.isEmpty }
                guard await confirm(.init(title: String(localized: "Delete entry?"),
                                          details: details,
                                          confirmLabel: String(localized: "Delete"))) else { return Self.cancelled }
                try await debts.deleteEntry(entry)
                return announce("Deleted debt", nil, describe(entry, person: person))
            }
        } catch {
            return Self.text(for: error)
        }
    }
}

// MARK: - Lookup

private extension AssistantActions {
    func findExpense(_ ref: String?) throws -> Expense {
        try lookup(ref, in: expenses.expenses)
    }

    func findIncome(_ ref: String?) throws -> Income {
        try lookup(ref, in: incomes.incomes)
    }

    func findEntry(_ ref: String?) throws -> DebtEntry {
        try lookup(ref, in: debts.entries)
    }

    func lookup<Item: Identifiable>(_ ref: String?, in items: [Item]) throws -> Item where Item.ID == String {
        guard let ref = ref?.trimmed, !ref.isEmpty else { throw ActionError(Self.missing("ref")) }
        switch IntelligencePrompts.resolve(ref: ref, in: items) {
        case .found(let item): return item
        case .notFound: throw ActionError("Error: no record with reference \(ref). Search again.")
        case .ambiguous: throw ActionError("Error: reference \(ref) matches several records. Search again.")
        }
    }

    /// Exact name (ignoring case and diacritics) wins over a partial match.
    func matchingPeople(named name: String) -> [Person] {
        let exact = debts.people.filter { Self.sameName($0.name, name) }
        return exact.isEmpty ? debts.people.filter { $0.name.localizedStandardContains(name) } : exact
    }

    func findPerson(named name: String) throws -> Person {
        let matches = matchingPeople(named: name)
        switch matches.count {
        case 0: throw ActionError("Error: no person named \(name).")
        case 1: return matches[0]
        default: throw ActionError(Self.ambiguous(matches))
        }
    }

    func owner(of entry: DebtEntry) -> Person? {
        debts.people.first { $0.id == entry.personID }
    }

    static func sameName(_ lhs: String, _ rhs: String) -> Bool {
        lhs.compare(rhs, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }
}

// MARK: - Text

private extension AssistantActions {
    struct ActionError: Error {
        let message: String
        init(_ message: String) { self.message = message }
    }

    static let cancelled = "The user cancelled. Nothing was deleted."
    static let nothingToChange = "Error: nothing to change. Ask the user what to change."
    static let invalidAmount = "Error: the amount must be greater than zero."

    static func missing(_ field: String) -> String {
        field == "ref" ? "Error: missing ref. Search for the record first." : "Error: missing \(field). Ask the user."
    }

    static func ambiguous(_ people: [Person]) -> String {
        "Error: several people match: \(people.map(\.name).joined(separator: ", ")). Ask which one."
    }

    static func text(for error: any Error) -> String {
        if let error = error as? ActionError { return error.message }
        return "Error: \(error.localizedDescription)"
    }

    static func kindText(_ kind: DebtEntryKind) -> String {
        switch kind {
        case .lent: String(localized: "Lent")
        case .borrowed: String(localized: "Borrowed")
        case .receivedPayment: String(localized: "Payment received")
        case .madePayment: String(localized: "Payment made")
        }
    }

    func money(_ amount: Double) -> String {
        amount.formattedMoney(code: currencyCode())
    }

    func isoDay(_ date: Date) -> String {
        date.formatted(Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
    }

    func resolvedDate(_ explicit: String?, _ daysAgo: Int?) -> Date? {
        Date.resolved(explicit: explicit, daysAgo: daysAgo, now: now(), calendar: calendar)
    }

    func describe(_ expense: Expense) -> String {
        "\(expense.name), \(money(expense.amount)) on \(isoDay(expense.date)) (\(expense.category.rawValue), \(expense.paymentMethod.rawValue))"
    }

    func describe(_ income: Income) -> String {
        "\(income.concept), \(money(income.amount)) on \(isoDay(income.date)) (\(income.source.rawValue))"
    }

    func describe(_ entry: DebtEntry, person: Person?) -> String {
        "\(person?.name ?? "?"), \(entry.kind.rawValue) \(money(entry.amount)) on \(isoDay(entry.date))"
    }

    /// Records the activity card and builds the reply: `"<title> #<ref>: <summary>."` (no ref after a deletion).
    /// The model always reads the English title; the card shows it localized.
    func announce(_ title: LocalizedStringResource, _ id: String?, _ summary: String) -> String {
        record(.init(systemImage: Self.systemImage(for: title.key),
                     title: String(localized: title),
                     detail: summary))
        let reference = id.map { " #\(IntelligencePrompts.ref(for: $0))" } ?? ""
        return "\(title.key)\(reference): \(summary)."
    }

    static func systemImage(for title: String) -> String {
        if title.hasPrefix("Created") { return "plus.circle" }
        if title.hasPrefix("Updated") { return "pencil.circle" }
        return "trash.circle"
    }
}

private extension Optional where Wrapped == String {
    var trimmed: String { self?.trimmed ?? "" }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
