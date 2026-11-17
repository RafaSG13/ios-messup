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

    static func csv(expenses: [Expense], deposits: [Deposit]) -> String {
        var rows: [(date: Date, fields: [String])] = []
        rows += expenses.map {
            ($0.date, ["expense", format($0.date), $0.name, format($0.amount), $0.category.rawValue, $0.paymentMethod.rawValue])
        }
        rows += deposits.map {
            ($0.date, ["deposit", format($0.date), $0.concept, format($0.amount), "", $0.foundingSource.rawValue])
        }
        let lines = rows
            .sorted { $0.date < $1.date }
            .map { $0.fields.map(escape).joined(separator: ",") }
        return ([header] + lines).joined(separator: "\r\n") + "\r\n"
    }

    // MARK: - Helpers

    private static func format(_ date: Date) -> String {
        date.formatted(.iso8601)
    }

    private static func format(_ amount: Double) -> String {
        String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), amount)
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else { return field }
        return "\"" + field.replacing("\"", with: "\"\"") + "\""
    }
}
