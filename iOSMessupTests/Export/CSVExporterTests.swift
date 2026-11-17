//
//  CSVExporterTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
@testable import iOSMessup
import Testing

struct CSVExporterTests {

    private let early = Date(timeIntervalSince1970: 1_700_000_000)
    private let late = Date(timeIntervalSince1970: 1_700_100_000)

    private func lines(_ csv: String) -> [String] {
        csv.components(separatedBy: "\r\n").filter { !$0.isEmpty }
    }

    @Test func emptyInputIsHeaderOnly() {
        #expect(lines(CSVExporter.csv(expenses: [], deposits: [])) == [CSVExporter.header])
        #expect(CSVExporter.header == "type,date,name,amount,category,payment_method_or_source")
    }

    @Test func rowsContainExpectedFields() {
        let expense = Expense(name: "Coffee", amount: 3.5, date: early, paymentMethod: .cash, category: .food)
        let deposit = Deposit(concept: "Pay", amount: 1200, date: late, foundingSource: .salary)
        let rows = lines(CSVExporter.csv(expenses: [expense], deposits: [deposit]))
        #expect(rows.count == 3)
        #expect(rows[1] == "expense,2023-11-14T22:13:20Z,Coffee,3.50,Food,Cash")
        #expect(rows[2] == "deposit,2023-11-16T02:00:00Z,Pay,1200.00,,Salary")
    }

    @Test func rowsAreOrderedByDateAscending() {
        let expense = Expense(name: "Late", amount: 1, date: late, paymentMethod: .cash, category: .food)
        let deposit = Deposit(concept: "Early", amount: 1, date: early, foundingSource: .salary)
        let rows = lines(CSVExporter.csv(expenses: [expense], deposits: [deposit]))
        #expect(rows[1].hasPrefix("deposit"))
        #expect(rows[2].hasPrefix("expense"))
    }

    @Test func quotesCommasAndQuotes() {
        let expense = Expense(name: "Joe's \"Best\", Café", amount: 1, date: early, paymentMethod: .cash, category: .food)
        let rows = lines(CSVExporter.csv(expenses: [expense], deposits: []))
        #expect(rows[1].contains("\"Joe's \"\"Best\"\", Café\""))
    }
}
