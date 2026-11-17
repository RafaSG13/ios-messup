//
//  Double+Utils.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import Foundation

extension Double {
    /// `1234.5` → "$1,234.50" (locale-aware; `code` is an ISO 4217 code, see `AppCurrency`).
    func formattedMoney(code: String) -> String {
        formatted(.currency(code: code))
    }

    /// `2900` → "$2.9K" (compact, for tight spaces such as chart annotations and progress labels).
    func formattedCompactMoney(code: String) -> String {
        formatted(.currency(code: code).notation(.compactName))
    }

    func formatToPercentageString() -> String {
        let percentage = Int((self * 100).rounded())
        return "\(percentage)%"
    }
}
