//
//  ExpenseDraft.swift
//  iOSMessup
//

import Foundation

/// What the on-device model understood from free text or a receipt. Every field is optional: the form only
/// overwrites the ones that are present, and the user always reviews the result before saving.
struct ExpenseDraft: Equatable {
    var name: String?
    var amount: Double?
    var date: Date?
    var paymentMethod: PaymentMethod?
    var category: Category?
}
