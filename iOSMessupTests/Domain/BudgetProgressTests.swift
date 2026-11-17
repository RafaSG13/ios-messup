//
//  BudgetProgressTests.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

@testable import iOSMessup
import Testing

struct BudgetProgressTests {
    @Test func isOkBelowEightyPercent() {
        let progress = BudgetProgress(spent: 79, limit: 100)
        #expect(progress.state == .ok)
    }

    @Test func isWarningAtExactlyEightyPercent() {
        #expect(BudgetProgress(spent: 80, limit: 100).state == .warning)
        #expect(BudgetProgress(spent: 100, limit: 100).state == .warning)
    }

    @Test func isOverOnlyAboveTheLimit() {
        #expect(BudgetProgress(spent: 100.01, limit: 100).state == .over)
    }

    @Test func fractionIsClamped() {
        #expect(BudgetProgress(spent: 50, limit: 100).fraction == 0.5)
        #expect(BudgetProgress(spent: 250, limit: 100).fraction == 1)
        #expect(BudgetProgress(spent: -10, limit: 100).fraction == 0)
    }

    @Test func remainingIsNegativeWhenOver() {
        #expect(BudgetProgress(spent: 130, limit: 100).remaining == -30)
        #expect(BudgetProgress(spent: 30, limit: 100).remaining == 70)
    }

    @Test func nonPositiveLimitIsOkWithZeroFraction() {
        for limit in [0.0, -50] {
            let progress = BudgetProgress(spent: 40, limit: limit)
            #expect(progress.state == .ok)
            #expect(progress.fraction == 0)
        }
    }
}
