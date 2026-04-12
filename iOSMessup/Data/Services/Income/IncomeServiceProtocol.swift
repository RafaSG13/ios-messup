//
//  IncomeServiceProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 16/12/25.
//

import Foundation
import SwiftUI

protocol IncomeServiceProtocol: AnyObject {
    var deposits: [Deposit] { get }
    var savingGoal: SavingGoal? { get }

    func load() async throws
    func createSavingGoal(_ goal: SavingGoal) async throws
    func createDeposit(_ deposit: Deposit) async throws
    func updateSavingGoal(with newValue: SavingGoal) async throws
    func updateDeposit(with newValue: Deposit) async throws
    func deleteSavingGoal() async throws
    func deleteDeposits(removeAt indices: IndexSet) async throws
    func deleteDeposit(_ deposit: Deposit) async throws
    func lastDeposits(limit: Int) -> [Deposit]
    func calculateTotalFounded() -> Double
    func calculateActualProgress() -> Double
    func filteredDeposits(on searchTerm: String) -> [Deposit]
}

extension EnvironmentValues {
    @Entry var incomeService: IncomeServiceProtocol = MockIncomeService()
}
