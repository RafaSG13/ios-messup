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
}
