//
//  IntelligencePrompts.swift
//  iOSMessup
//

import Foundation

/// Instructions and data snippets handed to the on-device model. Pure functions of their inputs, so they are
/// unit-tested; the model is only ever given figures computed here, never asked to calculate.
enum IntelligencePrompts {
    // MARK: - Instructions

    static func replyLanguage(_ locale: Locale) -> String {
        Locale(identifier: "en").localizedString(forLanguageCode: locale.language.languageCode?.identifier ?? "en") ?? "English"
    }

    static func draftInstructions(now: Date, calendar: Calendar) -> String {
        """
        Extract one personal expense from the user's text. Today is \(isoDay(now, calendar: calendar)), \
        \(now.formatted(Date.FormatStyle(locale: Locale(identifier: "en"), calendar: calendar, timeZone: calendar.timeZone).weekday(.wide))). \
        Leave a field empty when it is not mentioned. Never invent an amount.
        """
    }

    static let receiptInstructions = "Read the receipt image. Extract the merchant name, the total paid, the purchase date and the payment method when printed."

    static func summaryInstructions(locale: Locale) -> String {
        """
        You are the assistant of Messup, a personal finance app. Write 2–3 short sentences in second person, \
        in \(replyLanguage(locale)), summarizing the facts given. Use only those facts and copy the amounts \
        exactly as written. No investment advice.
        """
    }

    static func assistantInstructions(now: Date, currencyCode: String, calendar: Calendar = .current) -> String {
        """
        You are Messup's assistant. Answer questions about the user's own expenses, income, budget and saving goal \
        using the tools; never invent figures; if a tool returns no data, say so. Today is \(isoDay(now, calendar: calendar)). \
        Amounts are in \(currencyCode). You cannot create, edit or delete data. \
        Reply in the language of the question, in at most 80 words.
        """
    }

    // MARK: - Periods

    /// The period `periodsAgo` periods before the one containing `now`.
    static func period(kind: PeriodKind, periodsAgo: Int, now: Date, calendar: Calendar) -> Period {
        var period = Period(kind: kind, containing: now, calendar: calendar)
        for _ in 0..<max(periodsAgo, 0) {
            period = period.previous()
        }
        return period
    }

    // MARK: - Data

    static func summaryFacts(_ summary: PeriodSummary, monthlyLimit: Double?, currencyCode: String) -> String {
        let period = summary.period
        let calendar = period.calendar
        let lastDay = calendar.date(byAdding: .day, value: -1, to: period.end) ?? period.end
        var periodLine = "Period: \(period.kind.rawValue) from \(isoDay(period.start, calendar: calendar)) to \(isoDay(lastDay, calendar: calendar))"
        if summary.projectedSpent != nil {
            periodLine += " (in progress: day \(summary.elapsedDays) of \(period.dayCount))"
        }

        var lines = [periodLine, "Spent: \(money(summary.spent, currencyCode))"]
        if let change = summary.changeVersusPrevious {
            let percent = change.formatted(.percent.precision(.fractionLength(0)).sign(strategy: .always()))
            lines.append("Change versus the previous \(period.kind.rawValue) at the same point: \(percent)")
        }
        if let projected = summary.projectedSpent {
            lines.append("Projected total for the period: \(money(projected, currencyCode))")
        }
        if let monthlyLimit {
            lines.append("Budget: \(money(monthlyLimit, currencyCode)), remaining: \(money(monthlyLimit - summary.spent, currencyCode))")
        }

        let total = summary.categoryTotals.reduce(0) { $0 + $1.amount }
        let top = summary.categoryTotals.prefix(3).map { item in
            let share = total > 0 ? item.amount / total : 0
            return "\(item.category.rawValue) \(money(item.amount, currencyCode)) (\(share.formatted(.percent.precision(.fractionLength(0)))))"
        }
        if !top.isEmpty {
            lines.append("Top categories: " + top.joined(separator: "; "))
        }

        lines.append("Income: \(money(summary.income, currencyCode))")
        lines.append("Saved to the goal: \(money(summary.contributed, currencyCode))")
        lines.append("Balance: \(money(summary.balance, currencyCode))")
        return lines.joined(separator: "\n")
    }

    /// `summaryFacts` plus the category limits that are in warning or exceeded (months only).
    static func spendingReport(_ summary: PeriodSummary, budget: Budget?, currencyCode: String) -> String {
        let monthlyLimit = summary.period.kind == .month ? budget?.monthlyLimit : nil
        var lines = [summaryFacts(summary, monthlyLimit: monthlyLimit, currencyCode: currencyCode)]
        if summary.period.kind == .month, let budget {
            for item in summary.categoryTotals {
                guard let limit = budget.categoryLimits[item.category] else { continue }
                let progress = BudgetProgress(spent: item.amount, limit: limit)
                switch progress.state {
                case .ok: continue
                case .warning:
                    lines.append("Category limit close: \(item.category.rawValue) \(money(item.amount, currencyCode)) of \(money(limit, currencyCode))")
                case .over:
                    lines.append("Category limit exceeded: \(item.category.rawValue) \(money(item.amount, currencyCode)) of \(money(limit, currencyCode))")
                }
            }
        }
        return lines.joined(separator: "\n")
    }

    static let maximumListedExpenses = 10

    static func expenseSearch(_ expenses: [Expense],
                              query: String?,
                              category: Category?,
                              period: Period,
                              currencyCode: String) -> String {
        let text = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let matches = expenses
            .filter { period.contains($0.date) }
            .filter { category == nil || $0.category == category }
            .filter { text.isEmpty || $0.name.localizedStandardContains(text) }
            .sorted(by: >)
        guard !matches.isEmpty else { return "No matching expenses." }

        let total = matches.reduce(0) { $0 + $1.amount }
        let noun = matches.count == 1 ? "expense" : "expenses"
        var lines = ["\(matches.count) \(noun), total \(money(total, currencyCode))"]
        lines += matches.prefix(maximumListedExpenses).map {
            "\(isoDay($0.date, calendar: period.calendar)) · \($0.name) · \(money($0.amount, currencyCode)) · \($0.category.rawValue)"
        }
        return lines.joined(separator: "\n")
    }

    static func savingsReport(goal: SavingGoal?,
                              progress: SavingGoalProgress?,
                              contributions: [Contribution],
                              includeContributions: Bool,
                              currencyCode: String,
                              calendar: Calendar = .current) -> String {
        guard let goal else { return "No saving goal set." }
        var lines = ["Goal: \(goal.name)", "Target: \(money(goal.amount, currencyCode))"]
        if let progress {
            lines.append("Saved: \(money(progress.earned, currencyCode))")
            lines.append("Remaining: \(money(progress.remaining, currencyCode))")
        }
        if let date = goal.completionDate.date {
            lines.append("Target date: \(isoDay(date, calendar: calendar))")
        }
        if includeContributions {
            let latest = contributions.sorted(by: >).prefix(5)
            if latest.isEmpty {
                lines.append("No contributions yet.")
            } else {
                lines.append("Latest contributions:")
                lines += latest.map { "\(isoDay($0.date, calendar: calendar)) · \(money($0.amount, currencyCode))" }
            }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Formatting

    private static func money(_ amount: Double, _ currencyCode: String) -> String {
        amount.formattedMoney(code: currencyCode)
    }

    private static func isoDay(_ date: Date, calendar: Calendar) -> String {
        date.formatted(Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
    }
}
