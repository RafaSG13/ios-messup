//
//  ExpensesDataSourceSpy.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 23/1/25.
//

import Foundation

class ExpensesDataSourceSpy: ExpensesDataSourceProtocol {

    var readAllCalled: Bool = false
    var createCalled: Bool = false
    var updateCalled: Bool = false
    var deleteCalled: Bool = false
    var deleteAllCalled: Bool = false

    var readAllResponse: [Expense] = []

    func readAll() async throws -> [Expense] {
        readAllCalled = true
        return readAllResponse
    }

    func create(_ expense: Expense) async throws {
        createCalled = true
    }

    func delete(_ expense: Expense) async throws {
        deleteCalled = true
    }

    func deleteAll(_ expenses: [Expense]) async throws {
        deleteAllCalled = true
    }

    func update(_ expense: Expense) async throws {
        updateCalled = true
    }
    
    func setReadAllResponse(_ response: [Expense]) {
        self.readAllResponse = response
    }
}
