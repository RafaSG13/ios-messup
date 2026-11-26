//
//  CSVExporter.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - CSVExporter

/// Builds the RFC 4180 CSV shared from Settings.
enum CSVExporter {
    static let header = "type,date,name,amount,category,payment_method_or_source"

    private static let dateStyle = Date.ISO8601FormatStyle()

    /// Debt rows carry the person's name and the entry kind (the note is not exported).
    static func csv(expenses: [Expense], incomes: [Income], debts: [DebtEntry], people: [Person]) -> String {
        let names = Dictionary(people.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
        var rows: [(date: Date, line: String)] = []
        rows.reserveCapacity(expenses.count + incomes.count + debts.count)
        for expense in expenses {
            rows.append((expense.date, line(["expense", format(expense.date), expense.name, format(expense.amount),
                                             expense.category.rawValue, expense.paymentMethod.rawValue])))
        }
        for income in incomes {
            rows.append((income.date, line(["income", format(income.date), income.concept, format(income.amount),
                                            "", income.source.rawValue])))
        }
        for debt in debts {
            rows.append((debt.date, line(["debt", format(debt.date), names[debt.personID] ?? "", format(debt.amount),
                                          "", debt.kind.rawValue])))
        }
        rows.sort { $0.date < $1.date }

        var output = header + "\r\n"
        for row in rows {
            output += row.line
            output += "\r\n"
        }
        return output
    }

    // MARK: - Helpers

    private static func line(_ fields: [String]) -> String {
        fields.map(escape).joined(separator: ",")
    }

    private static func format(_ date: Date) -> String {
        date.formatted(dateStyle)
    }

    private static func format(_ amount: Double) -> String {
        // No `locale:` argument: it formats with the C locale (always "."), and passing a Locale made this 10x slower.
        String(format: "%.2f", amount)
    }

    private static func escape(_ field: String) -> String {
        // UTF-8 scan: the special characters are ASCII, and iterating `Character`s (grapheme breaking) was the slow part.
        guard field.utf8.contains(where: { $0 == UInt8(ascii: ",") || $0 == UInt8(ascii: "\"")
            || $0 == UInt8(ascii: "\n") || $0 == UInt8(ascii: "\r") }) else { return field }
        return "\"" + field.replacing("\"", with: "\"\"") + "\""
    }
}
