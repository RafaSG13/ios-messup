//
//  GetAllExpensesRequest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 10/4/25.
//

import Foundation

// MARK: - Get All
struct GetAllExpensesRequest: MURequest {
    var path: String { "expenses/" }
    var method: HTTPMethod { .get }
    var headers: [String: String] { ["Content-Type": "application/json"] }

    var body: Data? { nil }
}

// MARK: - Create
struct CreateExpenseRequest: MURequest {
    var path: String { "expenses/" }
    var method: HTTPMethod { .post }
    var headers: [String: String] { ["Content-Type": "application/json"] }

    var body: Data? {
        try? JSONEncoder.expenseEncoder.encode(expense)
    }

    let expense: Expense
}

// MARK: - Delete
struct DeleteExpenseRequest: MURequest {
    var path: String { "expenses/\(id)" }
    var method: HTTPMethod { .delete }
    var headers: [String: String] { ["Content-Type": "application/json"] }

    var body: Data? { nil }

    let id: String
}

// MARK: - Update
struct UpdateExpenseRequest: MURequest {
    var path: String { "expenses/\(expense.id)" }
    var method: HTTPMethod { .put }
    var headers: [String: String] { ["Content-Type": "application/json"] }

    var body: Data? {
        try? JSONEncoder.expenseEncoder.encode(expense)
    }

    let expense: Expense
}

// MARK: - Helper
extension JSONEncoder {
    static var expenseEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
