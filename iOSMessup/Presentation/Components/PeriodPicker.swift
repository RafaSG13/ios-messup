//
//  PeriodPicker.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

import SwiftUI
import MUDesignSystem

// MARK: - PeriodPicker

/// Week / Month / Year selector with previous/next navigation. The screen owns `kind` and `anchor` (any date inside
/// the shown period) and builds `Period(kind: kind, containing: anchor)` from them. Next is disabled once the
/// shown period is the current one, so the user cannot navigate into the future.
struct PeriodPicker: View {
    @Binding var kind: PeriodKind
    @Binding var anchor: Date
    var now: Date = .now
    var calendar: Calendar = .current

    private var period: Period {
        Period(kind: kind, containing: anchor, calendar: calendar)
    }

    private var isCurrent: Bool {
        period.contains(now)
    }

    var body: some View {
        VStack(spacing: MUSpacer.size03) {
            Picker("Period", selection: $kind) {
                Text("Week").tag(PeriodKind.week)
                Text("Month").tag(PeriodKind.month)
                Text("Year").tag(PeriodKind.year)
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Previous period", systemImage: "chevron.left") {
                    anchor = period.previous().start
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
                Spacer()
                Text(label)
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
                .disabled(isCurrent)
            }
        }
    }

    private var label: String {
        switch kind {
        case .month:
            return period.start.formatted(.dateTime.month(.wide).year())
        case .year:
            return period.start.formatted(.dateTime.year())
        case .week:
            let lastDay = calendar.date(byAdding: .day, value: -1, to: period.end) ?? period.end
            let style = Date.FormatStyle.dateTime.day().month(.abbreviated)
            return "\(period.start.formatted(style)) – \(lastDay.formatted(style))"
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var kind = PeriodKind.month
    @Previewable @State var anchor = Date.now
    List {
        Section { PeriodPicker(kind: $kind, anchor: $anchor) }
    }
}
