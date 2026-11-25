//
//  AssistantActionsTests.swift
//  iOSMessupTests
//

import Foundation
import Testing
@testable import iOSMessup

struct AssistantActionsTests {
    // MARK: - Harness

    private final class Recorder {
        var events: [AssistantActionCenter.ActionEvent] = []
        var requests: [AssistantActionCenter.ConfirmationRequest] = []
        var approves = true
    }

    private struct Harness {
        let expenses: MockExpensesService
        let incomes: MockIncomeService
        let budget: MockBudgetService
        let debts: MockDebtsService
        let recorder: Recorder
        let actions: AssistantActions

        init(expenses: [Expense] = [],
             incomes: [Income] = [],
             budget: Budget? = nil,
             people: [Person] = [],
             entries: [DebtEntry] = [],
             approves: Bool = true,
             shouldFail: Bool = false) {
            let expenseService = MockExpensesService(initialExpenses: expenses, delay: 0, shouldFail: shouldFail)
            let incomeService = MockIncomeService(initialIncomes: incomes, delay: 0, shouldFail: shouldFail)
            let budgetService = MockBudgetService(initialBudget: budget, delay: 0, shouldFail: shouldFail)
            let debtsService = MockDebtsService(initialPeople: people, initialEntries: entries, delay: 0,
                                                shouldFail: shouldFail)
            let recorder = Recorder()
            recorder.approves = approves
            self.recorder = recorder
            self.expenses = expenseService
            self.incomes = incomeService
            self.budget = budgetService
            self.debts = debtsService
            self.actions = AssistantActions(expenses: expenseService,
                                            incomes: incomeService,
                                            budget: budgetService,
                                            debts: debtsService,
                                            currencyCode: { "EUR" },
                                            now: { Harness.now },
                                            calendar: Harness.calendar,
                                            confirm: { request in
                                                recorder.requests.append(request)
                                                return recorder.approves
                                            },
                                            record: { recorder.events.append($0) })
        }

        static var calendar: Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            return calendar
        }

        /// 25 Nov 2026, 12:00 UTC.
        static var now: Date {
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: 12))!
        }
    }

    private func expenseArgs(_ action: GeneratedChangeAction,
                             ref: String? = nil,
                             name: String? = nil,
                             amount: Double? = nil,
                             daysAgo: Int? = nil) -> ExpenseChangeArguments {
        ExpenseChangeArguments(action: action, ref: ref, name: name, amount: amount, date: nil, daysAgo: daysAgo,
                               paymentMethod: nil, category: nil)
    }

    private func debtArgs(_ action: GeneratedChangeAction,
                          ref: String? = nil,
                          person: String? = nil,
                          kind: GeneratedDebtKind? = nil,
                          amount: Double? = nil) -> DebtChangeArguments {
        DebtChangeArguments(action: action, ref: ref, personName: person, kind: kind, amount: amount, date: nil,
                            daysAgo: nil, note: nil)
    }

    private func expense(id: String, _ name: String = "Coffee", _ amount: Double = 3.5) -> Expense {
        Expense(id: id, name: name, amount: amount, date: Harness.now, paymentMethod: .cash, category: .food)
    }

    // MARK: - Expenses

    @Test func createsAnExpenseWithDefaultsAndARelativeDate() async {
        let harness = Harness()

        let reply = await harness.actions.changeExpense(expenseArgs(.create, name: "Coffee", amount: 3.5, daysAgo: 1))

        let created = harness.expenses.expenses
        #expect(created.count == 1)
        #expect(created[0].name == "Coffee")
        #expect(created[0].date == Harness.calendar.date(byAdding: .day, value: -1, to: Harness.now))
        #expect(created[0].paymentMethod == .other)
        #expect(created[0].category == .miscellaneous)
        #expect(reply.hasPrefix("Created expense #\(IntelligencePrompts.ref(for: created[0].id))"))
        #expect(harness.recorder.events.count == 1)
        #expect(harness.recorder.events[0].title == "Created expense")
    }

    @Test func createWithoutAnAmountWritesNothing() async {
        let harness = Harness()

        let reply = await harness.actions.changeExpense(expenseArgs(.create, name: "Coffee"))

        #expect(reply.hasPrefix("Error: missing amount"))
        #expect(harness.expenses.expenses.isEmpty)
        #expect(harness.recorder.events.isEmpty)
    }

    @Test func updateChangesOnlyTheGivenFields() async {
        let original = expense(id: "AAAA1111-0000")
        let harness = Harness(expenses: [original])

        let reply = await harness.actions.changeExpense(expenseArgs(.update, ref: "#aaaa1111", amount: 4))

        let updated = harness.expenses.expenses[0]
        #expect(updated.amount == 4)
        #expect(updated.name == original.name)
        #expect(updated.date == original.date)
        #expect(updated.id == original.id)
        #expect(reply.hasPrefix("Updated expense"))
    }

    @Test func updateWithNothingToChangeIsAnError() async {
        let harness = Harness(expenses: [expense(id: "AAAA1111-0000")])

        let reply = await harness.actions.changeExpense(expenseArgs(.update, ref: "aaaa1111"))

        #expect(reply.hasPrefix("Error: nothing to change"))
        #expect(harness.recorder.events.isEmpty)
    }

    @Test func unknownShortAndAmbiguousReferencesAreErrors() async {
        let harness = Harness(expenses: [expense(id: "AAAA1111-0000"), expense(id: "AAAA1111-9999")])

        let unknown = await harness.actions.changeExpense(expenseArgs(.update, ref: "ffff0000", amount: 1))
        let short = await harness.actions.changeExpense(expenseArgs(.update, ref: "aa", amount: 1))
        let ambiguous = await harness.actions.changeExpense(expenseArgs(.update, ref: "aaaa1111", amount: 1))

        #expect(unknown.hasPrefix("Error: no record with reference"))
        #expect(short.hasPrefix("Error: no record with reference"))
        #expect(ambiguous.contains("matches several records"))
        #expect(harness.expenses.expenses.allSatisfy { $0.amount == 3.5 })
    }

    @Test func declinedDeletionKeepsTheExpense() async {
        let harness = Harness(expenses: [expense(id: "AAAA1111-0000")], approves: false)

        let reply = await harness.actions.changeExpense(expenseArgs(.delete, ref: "aaaa1111"))

        #expect(reply == "The user cancelled. Nothing was deleted.")
        #expect(harness.expenses.expenses.count == 1)
        #expect(harness.recorder.events.isEmpty)
    }

    @Test func approvedDeletionRemovesTheExpenseAfterAskingWithItsDetails() async {
        let harness = Harness(expenses: [expense(id: "AAAA1111-0000")])

        let reply = await harness.actions.changeExpense(expenseArgs(.delete, ref: "aaaa1111"))

        #expect(harness.expenses.expenses.isEmpty)
        #expect(reply.hasPrefix("Deleted expense"))
        #expect(harness.recorder.events.map(\.title) == ["Deleted expense"])
        let request = harness.recorder.requests[0]
        #expect(request.title == "Delete expense?")
        #expect(request.details[0].contains("Coffee"))
        #expect(request.details[0].contains(3.5.formattedMoney(code: "EUR")))
    }

    // MARK: - Income

    @Test func createsIncomeWithOtherAsTheDefaultSource() async {
        let harness = Harness()

        let args = IncomeChangeArguments(action: .create, ref: nil, concept: "Gift", amount: 50, date: "2026-11-01",
                                         daysAgo: nil, source: nil)
        _ = await harness.actions.changeIncome(args)

        #expect(harness.incomes.incomes.count == 1)
        #expect(harness.incomes.incomes[0].source == .other)
        #expect(harness.incomes.incomes[0].date == Harness.calendar.date(from: DateComponents(year: 2026, month: 11, day: 1)))
    }

    // MARK: - People and debts

    @Test func debtForAnUnknownPersonCreatesThePersonFirst() async {
        let harness = Harness()

        let reply = await harness.actions.changeDebt(debtArgs(.create, person: "Pedro", kind: .lent, amount: 20))

        let person = harness.debts.people.first
        #expect(person?.name == "Pedro")
        #expect(person?.contactIdentifier == nil)
        #expect(harness.debts.balance(of: person!) == 20)
        #expect(harness.recorder.events.map(\.title) == ["Added person", "Created debt"])
        #expect(reply.hasPrefix("Created debt #"))
    }

    @Test func debtForAnAmbiguousNameChangesNothing() async {
        let people = [Person(name: "Sam Carter"), Person(name: "Sam Lee")]
        let harness = Harness(people: people)

        let reply = await harness.actions.changeDebt(debtArgs(.create, person: "Sam", kind: .lent, amount: 20))

        #expect(reply.hasPrefix("Error: several people match: "))
        #expect(harness.debts.entries.isEmpty)
        #expect(harness.debts.people.count == 2)
        #expect(harness.recorder.events.isEmpty)
    }

    @Test func exactNameWinsOverPartialMatches() async {
        let people = [Person(name: "Sam"), Person(name: "Samantha")]
        let harness = Harness(people: people)

        _ = await harness.actions.changeDebt(debtArgs(.create, person: "sam", kind: .borrowed, amount: 5))

        #expect(harness.debts.entries.count == 1)
        #expect(harness.debts.balance(of: people[0]) == -5)
    }

    @Test func deletingAPersonAsksWithTheirSummaryAndCascades() async {
        let alex = Person(name: "Alex")
        let entries = (1...3).map { DebtEntry(personID: alex.id, kind: .lent, amount: 10, date: Harness.now.addingTimeInterval(Double($0))) }
        let other = Person(name: "Sam")
        let kept = DebtEntry(personID: other.id, kind: .lent, amount: 1, date: Harness.now)
        let harness = Harness(people: [alex, other], entries: entries + [kept])

        let reply = await harness.actions.changePerson(PersonChangeArguments(action: .delete, name: "alex", newName: nil))

        #expect(harness.debts.people == [other])
        #expect(harness.debts.entries == [kept])
        let request = harness.recorder.requests[0]
        #expect(request.details.contains("3 debts and payments"))
        #expect(request.details.contains { $0.hasPrefix("Balance: owes you") })
        #expect(reply.hasPrefix("Deleted Alex"))
    }

    @Test func renamingAPerson() async {
        let alex = Person(name: "Alex")
        let harness = Harness(people: [alex])

        let reply = await harness.actions.changePerson(PersonChangeArguments(action: .rename, name: "Alex", newName: "Alexandra"))

        #expect(harness.debts.people.map(\.name) == ["Alexandra"])
        #expect(reply == "Renamed Alex to Alexandra.")
    }

    @Test func updatingADebtByReference() async {
        let alex = Person(name: "Alex")
        let entry = DebtEntry(id: "BBBB2222-0000", personID: alex.id, kind: .lent, amount: 10, date: Harness.now)
        let harness = Harness(people: [alex], entries: [entry])

        _ = await harness.actions.changeDebt(debtArgs(.update, ref: "bbbb2222", amount: 15))

        #expect(harness.debts.entries[0].amount == 15)
        #expect(harness.debts.entries[0].kind == .lent)
    }

    // MARK: - Budget

    @Test func budgetCanBeSetThenGetCategoryLimitsThenLoseThem() async {
        let harness = Harness()

        _ = await harness.actions.changeBudget(BudgetChangeArguments(action: .set, monthlyLimit: 1000, category: nil,
                                                                     categoryLimit: nil))
        #expect(harness.budget.budget?.monthlyLimit == 1000)

        _ = await harness.actions.changeBudget(BudgetChangeArguments(action: .set, monthlyLimit: nil, category: .food,
                                                                     categoryLimit: 200))
        #expect(harness.budget.budget?.monthlyLimit == 1000)
        #expect(harness.budget.budget?.categoryLimits == [.food: 200])

        _ = await harness.actions.changeBudget(BudgetChangeArguments(action: .set, monthlyLimit: nil, category: .food,
                                                                     categoryLimit: 0))
        #expect(harness.budget.budget?.categoryLimits.isEmpty == true)
    }

    @Test func categoryLimitWithoutABudgetIsAnError() async {
        let harness = Harness()

        let reply = await harness.actions.changeBudget(BudgetChangeArguments(action: .set, monthlyLimit: nil,
                                                                             category: .food, categoryLimit: 200))

        #expect(reply == "Error: set a monthly limit first.")
        #expect(harness.budget.budget == nil)
    }

    @Test func clearingTheBudgetAsksFirst() async {
        let declined = Harness(budget: Budget(monthlyLimit: 500), approves: false)
        let approved = Harness(budget: Budget(monthlyLimit: 500))
        let args = BudgetChangeArguments(action: .clear, monthlyLimit: nil, category: nil, categoryLimit: nil)

        _ = await declined.actions.changeBudget(args)
        _ = await approved.actions.changeBudget(args)

        #expect(declined.budget.budget != nil)
        #expect(approved.budget.budget == nil)
        #expect(approved.recorder.requests.map(\.title) == ["Delete budget?"])
    }

    // MARK: - Failures

    @Test func aFailingServiceBecomesAnErrorTextInsteadOfAThrow() async {
        let harness = Harness(shouldFail: true)

        let reply = await harness.actions.changeExpense(expenseArgs(.create, name: "Coffee", amount: 3.5))

        #expect(reply == "Error: Simulated error")
        #expect(harness.recorder.events.isEmpty)
    }
}
