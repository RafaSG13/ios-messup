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
        Dictionary(grouping: self) { calendar.startOfDay(for: $0[keyPath: date]) }
            .map { day, items in
                DaySection(day: day, items: items.sorted { $0[keyPath: date] > $1[keyPath: date] })
            }
            .sorted { $0.day > $1.day }
    }
}
