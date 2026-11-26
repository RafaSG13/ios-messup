//
//  IncomeServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import SwiftUI

protocol IncomeServiceProtocol: AnyObject {
    var incomes: [Income] { get }

    func load() async throws
    func createIncome(_ income: Income) async throws
    func updateIncome(with newValue: Income) async throws
    func deleteIncome(_ income: Income) async throws
    func lastIncomes(limit: Int) -> [Income]
    func filteredIncomes(on searchTerm: String) -> [Income]
}

extension EnvironmentValues {
    @Entry var incomeService: IncomeServiceProtocol = defaultIncomeService
    // A `static let`: the macro's getter runs on every fallback read, so `MockIncomeService()` there would allocate a new service each time.
    private static let defaultIncomeService = MockIncomeService()
}
