//
//  Calendar+Utils.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 22/1/25.
//

import Foundation

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        guard let startOfWeek = self.date(from: self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return false }
        let endOfWeek = self.date(byAdding: .day, value: 7, to: startOfWeek)!
        return date >= startOfWeek && date < endOfWeek
    }

    func actualMonthToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"

        return dateFormatter.string(from: Date())
    }
}
