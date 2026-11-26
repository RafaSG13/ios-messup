//
//  ExpensesCalendarView.swift
//  iOSMessup
//

import SwiftUI
import MUDesignSystem

// MARK: - ExpensesCalendarView

/// A month as a grid where every day is tinted by how much was spent (the more, the stronger), with the expenses of
/// the selected day listed below. `anchor` is shared with the overview, so both show the same month.
struct ExpensesCalendarView: View {
    @Binding var anchor: Date
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?
    @State private var selectedDay: Date?

    var body: some View {
        let month = CalendarMonth(containing: anchor)
        let day = effectiveDay(in: month.period)

        List {
            Section {
                MUCard {
                    VStack(spacing: MUSpacer.size03) {
                        CalendarMonthHeader(anchor: $anchor, period: month.period)
                        CalendarMonthGrid(month: month, selectedDay: day) { selectedDay = $0 }
                    }
                }
                .clearListRow(insets: EdgeInsets())
            }
            if let day {
                CalendarDaySection(day: day, selectedItem: $selectedItem, error: $error)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(MUSpacer.size04)
    }

    /// The tapped day when it belongs to the month shown, otherwise today when the month is the current one.
    private func effectiveDay(in period: Period) -> Date? {
        if let selectedDay, period.contains(selectedDay) { return selectedDay }
        return period.contains(.now) ? period.calendar.startOfDay(for: .now) : nil
    }
}

// MARK: - CalendarMonthHeader

private struct CalendarMonthHeader: View {
    @Binding var anchor: Date
    let period: Period

    var body: some View {
        HStack {
            Button("Previous period", systemImage: "chevron.left") {
                anchor = period.previous().start
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            Spacer()
            Text(period.start, format: .dateTime.month(.wide).year())
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button("Next period", systemImage: "chevron.right") {
                anchor = period.next().start
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .disabled(period.contains(.now))
        }
    }
}

// MARK: - CalendarMonthGrid

/// Reads the expenses itself, so only the grid is re-evaluated when they change.
private struct CalendarMonthGrid: View {
    @Environment(\.expenseService) private var expenseService
    let month: CalendarMonth
    let selectedDay: Date?
    let onSelect: (Date) -> Void

    private enum ViewTraits {
        static let spacing = MUSpacer.size01
    }

    var body: some View {
        let totals = expenseService.expenses.filter { month.period.contains($0.date) }.totalsByDay()
        let maximum = totals.values.max() ?? 0
        let columns = Array(repeating: GridItem(.flexible(), spacing: ViewTraits.spacing), count: 7)

        LazyVGrid(columns: columns, spacing: ViewTraits.spacing) {
            ForEach(Array(month.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            ForEach(0..<month.leadingBlanks, id: \.self) { _ in
                Color.clear
                    .accessibilityHidden(true)
            }
            ForEach(month.days, id: \.self) { day in
                CalendarDayCell(day: day,
                                amount: totals[day] ?? 0,
                                maximum: maximum,
                                isSelected: day == selectedDay,
                                onSelect: onSelect)
            }
        }
    }
}

// MARK: - CalendarDayCell

private struct CalendarDayCell: View {
    @Environment(\.currencyCode) private var currencyCode
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let day: Date
    let amount: Double
    /// The biggest day of the month, which gets the strongest tint.
    let maximum: Double
    let isSelected: Bool
    let onSelect: (Date) -> Void

    private enum ViewTraits {
        static let maximumTint = 0.5
        static let minimumTint = 0.12
        static let selectionWidth: CGFloat = 2
    }

    var body: some View {
        Button { onSelect(day) } label: {
            VStack(spacing: 0) {
                Text(day, format: .dateTime.day())
                    .font(.callout.weight(Calendar.current.isDateInToday(day) ? .bold : .regular))
                    .foregroundStyle(.primary)
                if !dynamicTypeSize.isAccessibilitySize {
                    // A hidden placeholder keeps every row the same height.
                    Text(amount > 0 ? amount.formattedCompactMoney(code: currencyCode) : "0")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .opacity(amount > 0 ? 1 : 0)
                }
            }
            .padding(.vertical, MUSpacer.size02)
            .frame(maxWidth: .infinity)
            .background(tint, in: .rect(cornerRadius: MURadius.small))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: MURadius.small)
                        .strokeBorder(Color.primary, lineWidth: ViewTraits.selectionWidth)
                }
            }
            .contentShape(.rect(cornerRadius: MURadius.small))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(day, format: .dateTime.weekday(.wide).day().month(.wide)))
        .accessibilityValue(amount > 0 ? Text(amount.formattedMoney(code: currencyCode)) : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// Square-root scale, so one very expensive day does not wash out the rest.
    private var tint: Color {
        guard amount > 0, maximum > 0 else { return .clear }
        let intensity = (amount / maximum).squareRoot()
        let range = ViewTraits.maximumTint - ViewTraits.minimumTint
        return Color.accentColor.opacity(ViewTraits.minimumTint + range * intensity)
    }
}

// MARK: - CalendarDaySection

/// The expenses of the selected day, newest first, with the day's total in the header.
private struct CalendarDaySection: View {
    @Environment(\.expenseService) private var expenseService
    @Environment(\.currencyCode) private var currencyCode
    let day: Date
    @Binding var selectedItem: Expense?
    @Binding var error: (any Error)?

    var body: some View {
        let calendar = Calendar.current
        let expenses = expenseService.expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted(by: >)
        let total = expenses.reduce(0) { $0 + $1.amount }

        Section {
            if expenses.isEmpty {
                Text("No expenses on this day")
                    .foregroundStyle(.secondary)
            }
            ForEach(expenses) { expense in
                ExpenseListRow(expense: expense, selectedItem: $selectedItem, error: $error)
            }
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.title3.bold())
                    .foregroundStyle(Color.primary)
                Spacer()
                if total > 0 {
                    Text(total.formattedMoney(code: currencyCode))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .textCase(nil)
        }
    }
}

// MARK: - Previews

#Preview("Mock data") {
    NavigationStack {
        ExpensesCalendarView(anchor: .constant(.now), selectedItem: .constant(nil), error: .constant(nil))
            .navigationTitle("Expenses")
    }
}

#Preview("Accessibility size") {
    NavigationStack {
        ExpensesCalendarView(anchor: .constant(.now), selectedItem: .constant(nil), error: .constant(nil))
            .navigationTitle("Expenses")
    }
    .dynamicTypeSize(.accessibility3)
}
