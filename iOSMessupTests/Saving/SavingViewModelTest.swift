//
//  SavingViewModelTest.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 25/1/25.
//

@testable import iOSMessup
import Foundation
import Testing

struct SavingViewModelTest {

    @Test func loadViewModel() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let depositResponse = [Deposit.mock]
        let goalResponse = SavingGoal.mock
        spy.readAllDepositsResponse = depositResponse
        spy.readGoalResponse = goalResponse
        try await sut.load()

        #expect(spy.readGoalCalled == true)
        #expect(spy.readAllDepositsCalled == true)
        #expect(sut.deposits == depositResponse)
        #expect(sut.savingGoal == goalResponse)
    }

    @Test func loadViewModelSavingGoalEmpty() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        spy.readGoalResponse = nil
        try await sut.load()

        #expect(sut.savingGoal == nil)
        #expect(spy.readGoalCalled == true)
    }

    @Test func loadViewModelDepositsEmpty() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)
        
        spy.readAllDepositsResponse = []
        try await sut.load()
        
        #expect(sut.deposits.isEmpty)
        #expect(spy.readAllDepositsCalled == true)
    }

    @Test func createGoal() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let goal = SavingGoal.mock
        try await sut.createSavingGoal(goal)

        #expect(spy.createGoalCalled == true)
        #expect(sut.savingGoal == SavingGoal.mock)
    }

    @Test func createDeposit() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        try await sut.createDeposit(Deposit.mock)
        
        #expect(spy.createDepositCalled == true)
        #expect(sut.deposits.contains(Deposit.mock))
    }

    @Test func updateGoal() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let initialGoal = SavingGoal.mock
        try await sut.createSavingGoal(initialGoal)
        let newGoal = SavingGoal(id: initialGoal.id, name: "Updated goal", completionDate: .undefined, amount: 100, savingCategory: .bigEvent)
        try await sut.updateSavingGoal(with: newGoal)

        #expect(spy.updateGoalCalled == true)
        #expect(sut.savingGoal == newGoal)
        #expect(sut.savingGoal != initialGoal)
    }

    @Test func updateDeposit() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let initialDeposit = Deposit.mock
        try await sut.createDeposit(initialDeposit)
        let newDeposit = Deposit(id: initialDeposit.id, concept: "Updated deposit", amount: 100, date: Date(), foundingSource: .bonuses)
        try await sut.updateDeposit(with: newDeposit)

        #expect(spy.updateDepositCalled == true)
        #expect(sut.deposits.contains(newDeposit))
    }

    @Test func deleteDeposits() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        try? await sut.createDeposit(Deposit.mock)
        try? await sut.deleteDeposits(removeAt: .init(integer: 0))

        #expect(spy.createDepositCalled == true)
        #expect(spy.deleteAllDepositsCalled == true)
        #expect(!sut.deposits.contains(Deposit.mock))
        #expect(sut.deposits.count == 0)
    }

    @Test func calculateTotalFounded() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let deposit1 = Deposit.mock
        let deposit2 = Deposit.mock
        spy.setReadAllDepositsResponse([deposit1, deposit2])
        try? await sut.load()
        let result = sut.calculateTotalFounded()

        #expect(result == deposit1.amount + deposit2.amount)
    }

    @Test func calculateActualProgressWhenNoGoal() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let response = Deposit.mockArray
        spy.setReadAllDepositsResponse(response)

        try? await sut.load()
        let result = sut.calculateActualProgress()

        #expect(result == 0)
    }

    @Test func calculateActualProgress() async throws {
        let spy = SavingDataSourceSpy()
        let sut = SavingViewModel(dataSource: spy)

        let depositResponse = [Deposit.mock] // amount = 1200
        let goalResponse = SavingGoal.mock // amount = 2000
        spy.setReadAllDepositsResponse(depositResponse)
        spy.setReadGoalResponse(goalResponse)

        try? await sut.load()
        let result = sut.calculateActualProgress()

        #expect(result == 0.6)
    }
}
