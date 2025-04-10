//
//  GetAllExpensesRequest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 10/4/25.
//


//
//  GetAllExpensesRequest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 10/4/25.
//

import Foundation

struct GetAllExpensesRequest: MURequest {
    var path: String { "expenses/" }
    var method: HTTPMethod { .get }
    
    var body: Data? { nil }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}


struct CreateExpenseRequest: MURequest {
    var path: String { "expenses/" }
    var method: HTTPMethod { .post }

    var expense: Expense

    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(expense)
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
