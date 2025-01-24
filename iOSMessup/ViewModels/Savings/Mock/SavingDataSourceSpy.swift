//
//  SavingDataSourceSpy.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 24/1/25.
//

class SavingDataSourceSpy: SavingsDataSourceProtocol {

    var readAllDepositsCalled: Bool = false
    var readGoalCalled: Bool = false
    var createGoalCalled: Bool = false
    var createDepositCalled: Bool = false
    var updateGoalCalled: Bool = false
    var updateDepositCalled: Bool = false
    var deleteGoalCalled: Bool = false
    var deleteAllDepositsCalled: Bool = false

    var readAllDepositsResponse: [Deposit] = []
    var readGoalResponse: SavingGoal?

    func readAllDeposits() async throws -> [Deposit] {
        readAllDepositsCalled = true
        return readAllDepositsResponse
    }

    func readGoal() async throws -> SavingGoal? {
        readGoalCalled = true
        return readGoalResponse
    }

    func create(_ goal: SavingGoal) async throws {
        createGoalCalled = true
    }

    func create(_ deposit: Deposit) async throws {
        createDepositCalled = true
    }

    func update(_ goal: SavingGoal) async throws {
        updateGoalCalled = true
    }

    func update(_ deposit: Deposit) async throws {
        updateDepositCalled = true
    }

    func delete(_ goal: SavingGoal) async throws {
        deleteGoalCalled = true
    }

    func deleteAll(_ deposits: [Deposit]) async throws {
        deleteAllDepositsCalled = true
    }

    // Helper methods to set mock responses
    func setReadAllDepositsResponse(_ response: [Deposit]) {
        self.readAllDepositsResponse = response
    }

    func setReadGoalResponse(_ response: SavingGoal?) {
        self.readGoalResponse = response
    }
}
