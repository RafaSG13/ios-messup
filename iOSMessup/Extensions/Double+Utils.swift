//
//  Double+Utils.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 21/1/25.
//

import Foundation

extension Double {
    func toMoneyString() -> String {
        let roundedValue = ceil(self * 10) / 10.0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formattedString = formatter.string(from: NSNumber(value: roundedValue)) {
            return "\(formattedString) $"
        } else {
            return "0.00 $"
        }
    }

    func toAbbreviateMoneyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 1
        
        let number: Double
        let suffix: String
        
        if self >= 1_000_000_000_000 {
            number = self / 1_000_000_000_000
            suffix = "B"
        } else if self >= 1_000_000_000 {
            number = self / 1_000_000_000
            suffix = "B"
        } else if self >= 1_000_000 {
            number = self / 1_000_000
            suffix = "M"
        } else if self >= 1_000 {
            number = self / 1_000
            suffix = "k"
        } else {
            number = self
            suffix = ""
        }
        
        let formattedNumber = formatter.string(from: NSNumber(value: number)) ?? "$0.0"
        return formattedNumber + suffix
    }

    func formatToPercentageString() -> String {
        let percentage = Int((self * 100).rounded())
        return "\(percentage)%"
    }
}

