//
//  DaySection.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import Foundation

// MARK: - DaySection

/// Items that happened on the same calendar day, used to build sectioned lists.
struct DaySection<Item: Identifiable>: Identifiable {
    /// Start of the day in the calendar used to group.
    let day: Date
    let items: [Item]

    var id: Date { day }
}

extension Sequence where Element: Identifiable {
    /// Groups the elements by calendar day of `date`. Sections are newest day first and the items of each section
    /// are newest first, which is the order lists show them in.
    func groupedByDay(using calendar: Calendar = .current, date: KeyPath<Element, Date>) -> [DaySection<Element>] {
        // One sort, then a single pass: `startOfDay` runs once per day instead of once per element.
        let newestFirst = sorted { $0[keyPath: date] > $1[keyPath: date] }
        var sections: [DaySection<Element>] = []
        var dayStart = Date.distantFuture
        var items: [Element] = []
        for element in newestFirst {
            let value = element[keyPath: date]
            if value < dayStart {
                if !items.isEmpty { sections.append(DaySection(day: dayStart, items: items)) }
                items = []
                dayStart = calendar.startOfDay(for: value)
            }
            items.append(element)
        }
        if !items.isEmpty { sections.append(DaySection(day: dayStart, items: items)) }
        return sections
    }
}
