//
//  BudgetAlertTests.swift
//  iOSMessupTests
//
//  Created by Rafael Serrano Gamarra on 18/11/26.
//

import Foundation
import Testing
@testable import iOSMessup

struct BudgetAlertTests {
    private let month = Date(timeIntervalSince1970: 1_700_000_000)
    private let nextMonth = Date(timeIntervalSince1970: 1_702_600_000)

    @Test func belowEightyPercentStaysQuiet() {
        #expect(BudgetAlert.pending(spent: 799, limit: 1000, last: nil, monthStart: month) == nil)
    }

    @Test func eightyPercentRaisesWarning() {
        #expect(BudgetAlert.pending(spent: 800, limit: 1000, last: nil, monthStart: month) == .warning)
    }

    @Test func exactLimitIsStillWarningAndExceedingIsOver() {
        #expect(BudgetAlert.pending(spent: 1000, limit: 1000, last: nil, monthStart: month) == .warning)
        #expect(BudgetAlert.pending(spent: 1000.01, limit: 1000, last: nil, monthStart: month) == .over)
    }

    @Test func oneBigExpenseSkipsWarningAndRaisesOver() {
        #expect(BudgetAlert.pending(spent: 1500, limit: 1000, last: nil, monthStart: month) == .over)
    }

    @Test func deliveredLevelIsNotRepeatedInTheSameMonth() {
        let mark = BudgetAlertMark(monthStart: month, level: .warning)
        #expect(BudgetAlert.pending(spent: 900, limit: 1000, last: mark, monthStart: month) == nil)
    }

    @Test func warningEscalatesToOverOnce() {
        let warned = BudgetAlertMark(monthStart: month, level: .warning)
        #expect(BudgetAlert.pending(spent: 1100, limit: 1000, last: warned, monthStart: month) == .over)
        let over = BudgetAlertMark(monthStart: month, level: .over)
        #expect(BudgetAlert.pending(spent: 1200, limit: 1000, last: over, monthStart: month) == nil)
    }

    @Test func overAlreadyDeliveredSilencesWarningWhenSpendingDrops() {
        let over = BudgetAlertMark(monthStart: month, level: .over)
        #expect(BudgetAlert.pending(spent: 900, limit: 1000, last: over, monthStart: month) == nil)
    }

    @Test func newMonthRearmsAlerts() {
        let over = BudgetAlertMark(monthStart: month, level: .over)
        #expect(BudgetAlert.pending(spent: 900, limit: 1000, last: over, monthStart: nextMonth) == .warning)
    }

    @Test func nonPositiveLimitNeverAlerts() {
        #expect(BudgetAlert.pending(spent: 50, limit: 0, last: nil, monthStart: month) == nil)
    }
}
