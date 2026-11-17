//
//  SavingGoalProgressTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct SavingGoalProgressTests {
    @Test func partialProgress() {
        let progress = SavingGoalProgress(earned: 1_000, target: 4_000)

        #expect(progress.fraction == 0.25)
        #expect(progress.remaining == 3_000)
    }

    @Test func overshootClampsFractionAndRemaining() {
        let progress = SavingGoalProgress(earned: 6_000, target: 5_000)

        #expect(progress.fraction == 1)
        #expect(progress.remaining == 0)
    }

    @Test func zeroTargetHasNoProgress() {
        let progress = SavingGoalProgress(earned: 100, target: 0)

        #expect(progress.fraction == 0)
        #expect(progress.remaining == 0)
    }

    @Test func completionDateExposesFixedDateOnly() {
        let date = Date()

        #expect(CompletionDate.fixed(date).date == date)
        #expect(CompletionDate.undefined.date == nil)
    }
}
