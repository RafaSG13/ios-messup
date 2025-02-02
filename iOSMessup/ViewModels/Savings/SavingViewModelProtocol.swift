//
//  SavingViewModelProtocol.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Observation
import SwiftUI

protocol SavingViewModelProtocol: Observable {
    var savingGoal: SavingGoal? { get }
    var deposits: [Deposit] { get }

    func load() async throws
    func lastDeposits(limit: Int) -> [Deposit]
    func calculateTotalFounded() -> Double
    func updateSavingGoal(with newValue: SavingGoal) async throws
    func createSavingGoal(_ goal: SavingGoal) async throws
    func deleteSavingGoal() async throws
    func createDeposit(_ deposit: Deposit) async throws
    func deleteDeposits(removeAt indices: IndexSet) async throws
    func updateDeposit(with newValue: Deposit) async throws
    func calculateActualProgress() -> Double
    func filteredDeposits(on searchTerm: String) -> [Deposit]
}

struct SavingViewModelKey: EnvironmentKey {
    static let defaultValue: any SavingViewModelProtocol = SavingViewModelMock()
}

extension EnvironmentValues {
    var savingVM: any SavingViewModelProtocol {
        get { self[SavingViewModelKey.self] }
        set { self[SavingViewModelKey.self] = newValue }
    }
}
