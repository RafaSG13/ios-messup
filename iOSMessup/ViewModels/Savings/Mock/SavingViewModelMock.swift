//
//  SavingViewModelMock.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

import Foundation

@Observable class SavingViewModelMock: SavingViewModelProtocol {
    var deposits: [Deposit] = Deposit.mockArray
    var savingGoal: SavingGoal? = SavingGoal.mockArray.randomElement()
    
    func load() async throws {
        // Intentionally unimplemented
    }
    
    func createSavingGoal(_ goal: SavingGoal) async throws {
        // Intentionally unimplemented
    }
    
    func createDeposit(_ deposit: Deposit) async throws {
        // Intentionally unimplemented
    }
    
    func updateSavingGoal(with newValue: SavingGoal) async throws {
        // Intentionally unimplemented
    }
    
    func updateDeposit(with newValue: Deposit) async throws {
        // Intentionally unimplemented
    }
    
    func deleteSavingGoal() async throws {
        // Intentionally unimplemented
    }
    
    func deleteDeposits(removeAt indices: IndexSet) async throws {
        // Intentionally unimplemented
    }
    
    func lastDeposits(limit: Int) -> [Deposit] {
        deposits.suffix(limit)
    }
    
    func calculateTotalFounded() -> Double {
        deposits.reduce(0) { $0 + $1.amount }
    }
    
    func calculateActualProgress() -> Double {
        guard let savingGoal = savingGoal else { return 0 }
        return calculateTotalFounded() / savingGoal.amount
    }
}
